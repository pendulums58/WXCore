#include "online.h"

#include <algorithm>

#include "deck_check.h"

namespace wxframe {

namespace {

const char kLanAsk[] = "WXOSS?";
const char kLanAnswer[] = "WXOSS!";

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

std::vector<uint8_t> encode_room(const RoomState& r) {
  PacketWriter w;
  w.str(r.room_name).str(r.host_name).str(r.guest_name).u8(r.guest_ready).u8(r.guest_deck_ok).str(join_lines(r.guest_problems));
  w.u16(static_cast<uint32_t>(r.spectators.size()));
  for (const auto& s : r.spectators) w.str(s);
  w.u8(r.in_duel).u8(r.check_decks).u8(r.locked);
  return w.b;
}

RoomState decode_room(PacketReader& r) {
  RoomState s;
  s.room_name = r.str();
  s.host_name = r.str();
  s.guest_name = r.str();
  s.guest_ready = r.u8() != 0;
  s.guest_deck_ok = r.u8() != 0;
  s.guest_problems = split_lines(r.str());
  const uint32_t n = r.u16();
  for (uint32_t i = 0; i < n && r.ok; ++i) s.spectators.push_back(r.str());
  s.in_duel = r.u8() != 0;
  s.check_decks = r.u8() != 0;
  s.locked = r.u8() != 0;
  return s;
}

bool starts_with(const std::vector<uint8_t>& d, const char* tag) {
  const size_t n = std::char_traits<char>::length(tag);
  return d.size() >= n && std::equal(tag, tag + n, d.begin());
}

}  // namespace

// ── 방장 ──

bool OnlineHost::open(uint16_t port, const std::string& name, const std::string& room_name, const std::string& password,
                      std::string& err, bool local_only, uint16_t lan_port) {
  if (!net_.listen(port, err, local_only)) return false;
  net_port_ = port;
  room_ = RoomState{};
  room_.host_name = name.empty() ? "방장" : name;
  room_.room_name = room_name.empty() ? room_.host_name + "의 방" : room_name;
  room_.locked = !password.empty();
  password_ = password;
  std::string lan_err;
  // 같은 PC에서 방을 두 개 열면 방 찾기 포트는 먼저 연 쪽만 쓴다(직접 IP 접속은 된다)
  lan_.open(lan_port, local_only, lan_err);
  status = "포트 " + std::to_string(port) + "에서 기다리는 중" + (lan_.is_open() ? "" : " (LAN 방 찾기에는 안 보임)");
  return true;
}

void OnlineHost::close() {
  net_.close_all();
  lan_.close();
  members_.clear();
  spectators_.clear();
  guest_ = 0;
  deck_loaded_ = false;
  game_.on_message = nullptr;
  if (game_.running()) game_.reset();
  room_ = RoomState{};
}

OnlineHost::Member* OnlineHost::member(int peer) {
  for (auto& m : members_)
    if (m.peer == peer) return &m;
  return nullptr;
}

void OnlineHost::broadcast(uint8_t type, const std::vector<uint8_t>& body) {
  for (const auto& m : members_)
    if (m.joined) net_.send(m.peer, type, body);
}

void OnlineHost::send_room() {
  room_.spectators.clear();
  for (int p : spectators_)
    if (const Member* m = member(p)) room_.spectators.push_back(m->name);
  const Member* g = member(guest_);
  room_.guest_name = g ? g->name : "";
  if (!g) {
    room_.guest_ready = room_.guest_deck_ok = false;
    room_.guest_problems.clear();
  }
  room_.in_duel = game_.running();
  broadcast(kRoom, encode_room(room_));
}

void OnlineHost::add_chat(const std::string& name, const std::string& text) {
  if (text.empty()) return;
  chat_.push_back({name, text});
  ++chat_count_;
  if (chat_.size() > 200) chat_.erase(chat_.begin());
  broadcast(kChatOut, PacketWriter().str(name).str(text).b);
}

void OnlineHost::chat(const std::string& text) { add_chat(room_.host_name, text); }

// 사람이 나간 뒤 정리(끊김·강퇴 공통)
void OnlineHost::drop(int peer, const std::string& why) {
  const Member* m = member(peer);
  const std::string name = m ? m->name : "";
  if (!why.empty()) {
    net_.send(peer, kError, PacketWriter().str(why).b);
    net_.close_later(peer);  // 이유가 도착한 뒤 끊는다
  }
  std::erase_if(members_, [&](const Member& x) { return x.peer == peer; });
  std::erase(spectators_, peer);
  if (peer == guest_) {
    guest_ = 0;
    deck_loaded_ = false;
    if (game_.running()) {  // 대전자가 나가면 대전은 끝
      back_to_room();
    }
  }
  if (!name.empty()) status = name + " 님이 " + (why.empty() ? "나갔다" : "나갔다(" + why + ")");
  send_room();
}

void OnlineHost::kick_guest() {
  if (guest_) drop(guest_, "방장이 내보냈다");
}

void OnlineHost::kick_spectator(size_t index) {
  if (index < spectators_.size()) drop(spectators_[index], "방장이 내보냈다");
}

void OnlineHost::set_check_decks(bool on) {
  room_.check_decks = on;
  send_room();
}

bool OnlineHost::can_start() const {
  return guest_ && deck_loaded_ && room_.guest_ready && (!room_.check_decks || room_.guest_problems.empty()) &&
         !game_.running();
}

void OnlineHost::poll() {
  net_.poll();
  for (auto& e : net_.take_events()) {
    if (e.kind == Net::Event::Connected) {
      members_.push_back({e.peer, "", false});
    } else if (e.kind == Net::Event::Closed) {
      drop(e.peer, "");
    } else {
      on_packet(e);
    }
  }
  // LAN 방 찾기에 답한다: 「WXOSS!」 u32 프로토콜, u16 포트, str 방 이름, str 방장, u8 인원, u8 대전 중, u8 잠김
  std::string ip;
  uint16_t port = 0;
  std::vector<uint8_t> data;
  while (lan_.recv(ip, port, data)) {
    if (!starts_with(data, kLanAsk)) continue;
    PacketWriter w;
    w.b.assign(kLanAnswer, kLanAnswer + 6);
    w.u32(kProtocol).u16(net_port_).str(room_.room_name).str(room_.host_name).u8(guest_ ? 2 : 1).u8(game_.running()).u8(room_.locked);
    lan_.send_to(ip, port, w.b);
  }
  flush();
}

void OnlineHost::start_spectator(int peer) {
  net_.send(peer, kStart, PacketWriter().u8(2).b);
  // 처음부터 따라잡는다. 패킷 상한을 넘지 않게 메시지 경계에서 나눠 보낸다
  constexpr size_t kChunk = 1024 * 1024;
  size_t begin = 0, pos = 0;
  auto send = [&](size_t end) {
    if (end > begin) net_.send(peer, kMessages, std::vector<uint8_t>(history_.begin() + static_cast<std::ptrdiff_t>(begin), history_.begin() + static_cast<std::ptrdiff_t>(end)));
    begin = end;
  };
  while (pos + 4 <= history_.size()) {
    const size_t len = 4 + (history_[pos] | (history_[pos + 1] << 8) | (history_[pos + 2] << 16) | (static_cast<size_t>(history_[pos + 3]) << 24));
    if (pos > begin && pos + len - begin > kChunk) send(pos);
    pos += len;
  }
  send(history_.size());
}

void OnlineHost::on_packet(const Net::Event& e) {
  Member* m = member(e.peer);
  if (!m) return;
  PacketReader r{e.body};
  if (e.type == kJoin) {
    if (m->joined) return;  // 두 번 들어올 수 없다
    const uint32_t proto = r.u32(), schema = r.u32();
    const std::string name = r.str(), pass = r.str();
    const bool spectate = r.u8() != 0;
    if (!r.ok || proto != kProtocol || schema != WX_SCHEMA_VERSION) return drop(e.peer, "버전이 다르다(프로토콜·스키마)");
    if (pass != password_) return drop(e.peer, "비밀번호가 다르다");
    m->name = name.empty() ? "게스트" : name;
    m->joined = true;
    const bool seat = !spectate && !guest_ && !game_.running();
    if (seat) {
      guest_ = e.peer;
      deck_loaded_ = false;
      room_.guest_ready = room_.guest_deck_ok = false;
      room_.guest_problems.clear();
    } else {
      flush();  // 아직 안 보낸 메시지는 지난 기록으로도 가므로 먼저 보낸다(두 번 받지 않게)
      spectators_.push_back(e.peer);
    }
    net_.send(e.peer, kWelcome, PacketWriter().u8(seat ? 1 : 2).b);
    status = m->name + " 님이 " + (seat ? "들어왔다" : "관전하러 왔다");
    send_room();
    for (const auto& c : chat_) net_.send(e.peer, kChatOut, PacketWriter().str(c.name).str(c.text).b);
    if (!seat && game_.running()) start_spectator(e.peer);
    return;
  }
  if (!m->joined) return;
  switch (e.type) {
    case kDeck: {
      if (e.peer != guest_ || game_.running()) return;
      const std::string text = r.str();
      if (!r.ok) return;
      std::string err;
      wxtest::DeckFile d;
      room_.guest_problems.clear();
      room_.guest_ready = false;  // 덱을 바꾸면 준비를 다시
      deck_loaded_ = wxtest::load_deck_text(text, db_, d, err, "게스트 덱");
      if (!deck_loaded_) {
        room_.guest_problems.push_back(err);
      } else {
        guest_deck_ = std::move(d);
        const wxtest::DeckCheck c = wxtest::check_deck(db_, guest_deck_);
        room_.guest_problems = c.problems;
        if (!c.error.empty()) room_.guest_problems.push_back("검사 오류: " + c.error);
      }
      room_.guest_deck_ok = deck_loaded_ && room_.guest_problems.empty();
      send_room();
      break;
    }
    case kReady:
      if (e.peer != guest_ || game_.running()) return;
      room_.guest_ready = r.u8() != 0 && deck_loaded_ && (!room_.check_decks || room_.guest_problems.empty());
      send_room();
      break;
    case kResponse: {
      const auto& req = game_.request();
      if (e.peer != guest_ || !game_.running() || !req || req->player != 1) return;  // 게스트 차례가 아니면 무시
      const uint32_t n = r.u32();
      std::vector<uint32_t> picks;
      for (uint32_t i = 0; i < n && r.ok; ++i) picks.push_back(r.u32());
      if (!r.ok) return;
      game_.respond(picks);  // 거부되면 코어가 RETRY를 게스트 뷰로 보낸다
      break;
    }
    case kCancel: {
      const auto& req = game_.request();
      if (e.peer == guest_ && game_.running() && req && req->player == 1) game_.cancel();
      break;
    }
    case kChat: add_chat(m->name, r.str()); break;
    case kToSpectator:
      if (e.peer != guest_ || game_.running()) return;
      guest_ = 0;
      deck_loaded_ = false;
      spectators_.push_back(e.peer);
      net_.send(e.peer, kWelcome, PacketWriter().u8(2).b);
      send_room();
      break;
    case kToDuelist:
      if (guest_ || game_.running() || std::find(spectators_.begin(), spectators_.end(), e.peer) == spectators_.end()) return;
      std::erase(spectators_, e.peer);
      guest_ = e.peer;
      deck_loaded_ = false;
      room_.guest_ready = room_.guest_deck_ok = false;
      room_.guest_problems.clear();
      net_.send(e.peer, kWelcome, PacketWriter().u8(1).b);
      send_room();
      break;
    default: break;
  }
}

bool OnlineHost::start(const wxtest::DeckFile& mine, uint64_t seed, std::string& err) {
  if (!can_start()) {
    err = "게스트가 준비되지 않았다";
    return false;
  }
  for (auto& p : pending_) p.clear();
  history_.clear();
  game_.on_message = [this](int view, const uint8_t* m, size_t len) {
    if (view == 1 || view == 2) pending_[view].insert(pending_[view].end(), m, m + len);
    if (view == 2) history_.insert(history_.end(), m, m + len);
  };
  // 대전 메시지보다 먼저 시작을 알린다
  net_.send(guest_, kStart, PacketWriter().u8(1).b);
  for (int s : spectators_) net_.send(s, kStart, PacketWriter().u8(2).b);
  if (!game_.start(mine, guest_deck_, seed, false, err)) {
    game_.on_message = nullptr;
    broadcast(kBackToRoom, {});
    return false;
  }
  flush();
  send_room();
  return true;
}

void OnlineHost::back_to_room() {
  game_.on_message = nullptr;
  game_.reset();
  for (auto& p : pending_) p.clear();
  history_.clear();
  room_.guest_ready = false;
  broadcast(kBackToRoom, {});
  send_room();
}

void OnlineHost::flush() {
  if (!pending_[1].empty() && guest_) net_.send(guest_, kMessages, pending_[1]);
  if (!pending_[2].empty())
    for (int s : spectators_) net_.send(s, kMessages, pending_[2]);
  pending_[1].clear();
  pending_[2].clear();
}

// ── 게스트·관전자 ──

bool OnlineGuest::connect(const std::string& ip, uint16_t port, const std::string& name, const std::string& password,
                          bool spectate, std::string& err) {
  close();
  name_ = name;
  password_ = password;
  spectate_ = spectate;
  peer_ = net_.connect(ip, port, err);
  if (!peer_) return false;
  status = ip + ":" + std::to_string(port) + " 에 접속하는 중";
  return true;
}

void OnlineGuest::close() {
  net_.close_all();
  peer_ = 0;
  role_ = 0;
  connected_ = ready_ = false;
  room_ = RoomState{};
  chat_.clear();
  if (game_.running()) game_.reset();
}

void OnlineGuest::send_deck(const std::string& deck_json) {
  deck_json_ = deck_json;
  ready_ = false;
  if (connected_ && role_ == 1) net_.send(peer_, kDeck, PacketWriter().str(deck_json_).b);
}

void OnlineGuest::set_ready(bool on) {
  if (connected_ && role_ == 1) net_.send(peer_, kReady, PacketWriter().u8(on).b);
}

void OnlineGuest::chat(const std::string& text) {
  if (connected_ && !text.empty()) net_.send(peer_, kChat, PacketWriter().str(text).b);
}

void OnlineGuest::to_spectator() {
  if (connected_ && role_ == 1) net_.send(peer_, kToSpectator, {});
}

void OnlineGuest::to_duelist() {
  if (connected_ && role_ == 2) net_.send(peer_, kToDuelist, {});
}

void OnlineGuest::poll() {
  net_.poll();
  for (auto& e : net_.take_events()) {
    if (e.peer != peer_) continue;
    if (e.kind == Net::Event::Connected) {
      connected_ = true;
      net_.send(peer_, kJoin, PacketWriter().u32(kProtocol).u32(WX_SCHEMA_VERSION).str(name_).str(password_).u8(spectate_).b);
      status = "접속함";
    } else if (e.kind == Net::Event::Closed) {
      const bool was = connected_;
      peer_ = 0;
      role_ = 0;
      connected_ = false;
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
      role_ = static_cast<int>(r.u8());
      ready_ = false;
      if (role_ == 1 && !deck_json_.empty()) net_.send(peer_, kDeck, PacketWriter().str(deck_json_).b);
      status = role_ == 1 ? "대전자로 들어왔다" : "관전자로 들어왔다";
      break;
    case kRoom:
      room_ = decode_room(r);
      ready_ = role_ == 1 && room_.guest_ready;
      break;
    case kStart: {
      const int view = static_cast<int>(r.u8());
      if (view != role_ || (view != 1 && view != 2)) break;
      game_.start_remote(view, [this](const std::vector<uint32_t>& picks, bool cancel) {
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
    case kChatOut: {
      ChatLine c;
      c.name = r.str();
      c.text = r.str();
      chat_.push_back(std::move(c));
      ++chat_count_;
      if (chat_.size() > 200) chat_.erase(chat_.begin());
      break;
    }
    case kError: status = "방장: " + r.str(); break;
    default: break;
  }
}

// ── LAN 방 찾기 ──

LanFinder::LanFinder() = default;
LanFinder::~LanFinder() = default;

bool LanFinder::search(std::string& err, uint16_t lan_port, const std::vector<std::string>& extra, bool local_only) {
  rooms_.clear();
  if (!sock_.is_open() && !sock_.open(0, local_only, err)) return false;
  PacketWriter w;
  w.b.assign(kLanAsk, kLanAsk + 6);
  w.u32(kProtocol);
  if (!local_only) sock_.send_to("255.255.255.255", lan_port, w.b);
  for (const auto& ip : extra) sock_.send_to(ip, lan_port, w.b);
  return true;
}

void LanFinder::poll() {
  std::string ip;
  uint16_t port = 0;
  std::vector<uint8_t> data;
  while (sock_.recv(ip, port, data)) {
    if (!starts_with(data, kLanAnswer)) continue;
    std::vector<uint8_t> body(data.begin() + 6, data.end());
    PacketReader r{body};
    LanRoom room;
    room.ip = ip;
    if (r.u32() != kProtocol) continue;  // 다른 버전의 방은 안 보인다
    room.port = static_cast<uint16_t>(r.u16());
    room.room_name = r.str();
    room.host_name = r.str();
    room.players = static_cast<int>(r.u8());
    room.in_duel = r.u8() != 0;
    room.locked = r.u8() != 0;
    if (!r.ok) continue;
    const bool dup = std::any_of(rooms_.begin(), rooms_.end(), [&](const LanRoom& x) { return x.ip == room.ip && x.port == room.port; });
    if (!dup) rooms_.push_back(std::move(room));
  }
}

}  // namespace wxframe
