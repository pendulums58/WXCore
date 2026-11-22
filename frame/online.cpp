#include "online.h"

#include "deck_check.h"

namespace wxframe {

namespace {

std::string join_lines(const std::vector<std::string>& v) {
  std::string s;
  for (const auto& x : v) s += (s.empty() ? "" : "\n") + x;
  return s;
}

std::vector<std::string> split_lines(const std::string& s) {
  std::vector<std::string> out;
  std::string cur;
  for (char c : s) {
    if (c == '\n') {
      out.push_back(cur);
      cur.clear();
    } else {
      cur += c;
    }
  }
  if (!cur.empty()) out.push_back(cur);
  return out;
}

}  // namespace

// ── 방장 ──

bool OnlineHost::open(uint16_t port, const std::string& name, std::string& err, bool local_only) {
  name_ = name;
  if (!net_.listen(port, err, local_only)) return false;
  status = "포트 " + std::to_string(port) + "에서 기다리는 중";
  return true;
}

void OnlineHost::close() {
  net_.close_all();
  guest_ = 0;
  joined_ = deck_loaded_ = false;
  guest_name_.clear();
  guest_problems_.clear();
  game_.on_message = nullptr;
  if (game_.running()) game_.reset();
}

void OnlineHost::poll() {
  net_.poll();
  for (auto& e : net_.take_events()) {
    if (e.kind == Net::Event::Connected) {
      if (guest_) {  // 자리는 하나(관전은 N3)
        net_.send(e.peer, kError, PacketWriter().str("방이 찼다").b);
        net_.close(e.peer);
        continue;
      }
      guest_ = e.peer;
      status = "누군가 접속함";
    } else if (e.kind == Net::Event::Closed) {
      if (e.peer != guest_) continue;
      guest_ = 0;
      joined_ = deck_loaded_ = false;
      status = guest_name_ + " 님이 나갔다";
      guest_name_.clear();
      if (game_.running()) {
        game_.on_message = nullptr;
        game_.reset();
      }
    } else {
      on_packet(e);
    }
  }
  flush();
}

void OnlineHost::on_packet(const Net::Event& e) {
  if (e.peer != guest_) return;
  PacketReader r{e.body};
  switch (e.type) {
    case kJoin: {
      const uint32_t proto = r.u32(), schema = r.u32();
      const std::string name = r.str();
      if (!r.ok || proto != kProtocol || schema != WX_SCHEMA_VERSION) {
        net_.send(guest_, kError, PacketWriter().str("버전이 다르다(프로토콜·스키마)").b);
        net_.close(guest_);
        guest_ = 0;
        return;
      }
      guest_name_ = name.empty() ? "게스트" : name;
      joined_ = true;
      net_.send(guest_, kWelcome, PacketWriter().str(name_).b);
      status = guest_name_ + " 님이 들어왔다";
      break;
    }
    case kDeck: {
      const std::string text = r.str();
      std::string err;
      wxtest::DeckFile d;
      guest_problems_.clear();
      deck_loaded_ = wxtest::load_deck_text(text, db_, d, err, "게스트 덱");
      if (!deck_loaded_) {
        guest_problems_.push_back(err);
      } else {
        guest_deck_ = std::move(d);
        const wxtest::DeckCheck c = wxtest::check_deck(db_, guest_deck_);
        guest_problems_ = c.problems;
        if (!c.error.empty()) guest_problems_.push_back("검사 오류: " + c.error);
      }
      net_.send(guest_, kRoom, PacketWriter().str(deck_loaded_ ? join_lines(guest_problems_) : err).b);
      status = guest_name_ + " 님이 덱을 보냈다";
      break;
    }
    case kResponse: {
      const auto& req = game_.request();
      if (!game_.running() || !req || req->player != 1) return;  // 게스트 차례가 아니면 무시
      const uint32_t n = r.u32();
      std::vector<uint32_t> picks;
      for (uint32_t i = 0; i < n && r.ok; ++i) picks.push_back(r.u32());
      game_.respond(picks);  // 거부되면 코어가 RETRY를 게스트 뷰로 보낸다
      break;
    }
    case kCancel: {
      const auto& req = game_.request();
      if (game_.running() && req && req->player == 1) game_.cancel();
      break;
    }
    default: break;
  }
}

bool OnlineHost::start(const wxtest::DeckFile& mine, uint64_t seed, std::string& err) {
  if (!can_start()) {
    err = "게스트와 덱이 준비되지 않았다";
    return false;
  }
  pending_.clear();
  game_.on_message = [this](int view, const uint8_t* m, size_t len) {
    if (view == 1) pending_.insert(pending_.end(), m, m + len);
  };
  net_.send(guest_, kStart, PacketWriter().u8(1).b);  // 대전 메시지보다 먼저
  if (!game_.start(mine, guest_deck_, seed, false, err)) {
    game_.on_message = nullptr;
    return false;
  }
  flush();
  return true;
}

void OnlineHost::back_to_room() {
  game_.on_message = nullptr;
  game_.reset();
  pending_.clear();
  if (guest_) net_.send(guest_, kBackToRoom, {});
}

void OnlineHost::flush() {
  if (pending_.empty() || !guest_) return;
  net_.send(guest_, kMessages, pending_);
  pending_.clear();
}

// ── 게스트 ──

bool OnlineGuest::connect(const std::string& ip, uint16_t port, const std::string& name, std::string& err) {
  close();
  name_ = name;
  peer_ = net_.connect(ip, port, err);
  if (!peer_) return false;
  status = ip + ":" + std::to_string(port) + " 에 접속하는 중";
  return true;
}

void OnlineGuest::close() {
  net_.close_all();
  peer_ = 0;
  connected_ = deck_checked_ = false;
  host_name_.clear();
  deck_problems_.clear();
  if (game_.running()) game_.reset();
}

void OnlineGuest::send_deck(const std::string& deck_json) {
  deck_json_ = deck_json;
  deck_checked_ = false;
  if (connected_) net_.send(peer_, kDeck, PacketWriter().str(deck_json_).b);
}

void OnlineGuest::poll() {
  net_.poll();
  for (auto& e : net_.take_events()) {
    if (e.peer != peer_) continue;
    if (e.kind == Net::Event::Connected) {
      connected_ = true;
      net_.send(peer_, kJoin, PacketWriter().u32(kProtocol).u32(WX_SCHEMA_VERSION).str(name_).b);
      if (!deck_json_.empty()) net_.send(peer_, kDeck, PacketWriter().str(deck_json_).b);
      status = "접속함";
    } else if (e.kind == Net::Event::Closed) {
      const bool was = connected_;
      peer_ = 0;
      connected_ = false;
      host_name_.clear();
      if (game_.running()) game_.reset();
      if (status.rfind("방장:", 0) != 0) status = was ? "방장과 연결이 끊겼다" : "접속하지 못했다";
    } else {
      on_packet(e);
    }
  }
}

void OnlineGuest::on_packet(const Net::Event& e) {
  PacketReader r{e.body};
  switch (e.type) {
    case kWelcome:
      host_name_ = r.str();
      if (host_name_.empty()) host_name_ = "방장";
      status = host_name_ + " 님의 방에 들어왔다";
      break;
    case kRoom:
      deck_problems_ = split_lines(r.str());
      deck_checked_ = true;
      if (game_.running()) game_.reset();
      break;
    case kStart: {
      const int seat = static_cast<int>(r.u8());
      game_.start_remote(seat, [this](const std::vector<uint32_t>& picks, bool cancel) {
        if (cancel) {
          net_.send(peer_, kCancel, {});
          return;
        }
        PacketWriter w;
        w.u32(static_cast<uint32_t>(picks.size()));
        for (uint32_t p : picks) w.u32(p);
        net_.send(peer_, kResponse, w.b);
      });
      status = "대전 시작";
      break;
    }
    case kMessages:
      if (game_.remote()) game_.feed(e.body.data(), e.body.size());
      break;
    case kBackToRoom:
      if (game_.running()) game_.reset();
      status = "방으로 돌아왔다";
      break;
    case kError:
      status = "방장: " + r.str();
      break;
    default: break;
  }
}

}  // namespace wxframe
