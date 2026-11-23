#include "game.h"

#include <algorithm>
#include <cstring>
#include <utility>

namespace wxframe {

namespace {

struct Reader {
  const uint8_t* p;
  size_t n, pos = 0;
  uint32_t get(int bytes) {
    uint32_t v = 0;
    for (int i = 0; i < bytes && pos < n; ++i) v |= static_cast<uint32_t>(p[pos++]) << (8 * i);
    return v;
  }
};

int read_card(void* user, uint32_t cid, wx_card_data* out) {
  return static_cast<wxtest::CardDb*>(user)->fill(cid, out) ? 1 : 0;
}

const char* read_script(void* user, const char* name, size_t* len) {
  static std::string code;
  if (!static_cast<wxtest::CardDb*>(user)->read_script(name, code)) return nullptr;
  *len = code.size();
  return code.c_str();
}

std::vector<LogLine>* g_core_log = nullptr;
void on_log(void*, const char* msg) {
  if (!g_core_log) return;
  LogLine l;
  l.kind = LogLine::Error;
  l.text = std::string("[코어] ") + msg;
  g_core_log->push_back(std::move(l));
}

bool starts_with(const std::string& s, const char* p) { return s.rfind(p, 0) == 0; }

}  // namespace

Game::~Game() { reset(); }

void Game::reset() {
  if (duel_) wx_destroy_duel(duel_);
  duel_ = nullptr;
  req_.reset();
  remote_ = awaiting_ = false;
  send_ = nullptr;
}

void Game::start_remote(int seat, SendFn send) {
  reset();
  for (auto& l : log_) l.clear();
  for (auto& r : retry_) r.clear();
  for (auto& m : model_) m.reset();
  zones_.clear();
  zone_fixes_.clear();
  ended_ = false;
  winner_ = -1;
  practice_ = false;
  remote_ = true;
  seat_ = seat;
  send_ = std::move(send);
}

std::vector<FxEvent> Game::take_fx(int view) { return std::exchange(fx_[remote_ ? seat_ : view], {}); }

void Game::feed(const uint8_t* data, size_t n) {
  size_t pos = 0;
  while (pos + 6 <= n) {
    Reader rd{data + pos, n - pos};
    const size_t len = 4 + rd.get(4);
    if (pos + len > n) break;
    handle(seat_, data + pos, len);
    pos += len;
  }
  if (zones_.size() != model_[seat_].zones().size()) zones_ = model_[seat_].zones();
}

bool Game::start(const wxtest::DeckFile& p1, const wxtest::DeckFile& p2, uint64_t seed, bool practice,
                 std::string& err) {
  if (duel_) wx_destroy_duel(duel_);
  duel_ = nullptr;
  req_.reset();
  for (auto& l : log_) l.clear();
  for (auto& r : retry_) r.clear();
  for (auto& f : fx_) f.clear();
  fx_mute_ = false;
  ended_ = false;
  winner_ = -1;
  practice_ = practice;

  wx_duel_options o{};
  o.schema_version = WX_SCHEMA_VERSION;
  o.seed = seed;
  o.flags = practice ? WX_FLAG_TEST_MODE : 0;  // 연습 모드면 되돌리기를 쓸 수 있다
  o.first_player = 0xFF;
  o.card_reader = read_card;
  o.script_reader = read_script;
  o.log_handler = on_log;
  o.user = &db_;
  if (wx_create_duel(&o, &duel_) != WX_OK) {
    err = "대전 생성 실패";
    return false;
  }
  g_core_log = &log_[WX_VIEW_ALL];
  zones_.clear();
  for (auto& m : model_) m.reset();
  zone_fixes_.clear();
  // 덱에서 장마다 고른 판본도 넘긴다(화면용. 메시지에 실려 상대·관전자도 같은 그림을 본다)
  int seat = 0;
  for (const wxtest::DeckFile* d : {&p1, &p2}) {
    std::vector<uint16_t> mp, lp;
    for (size_t i = 0; i < d->main.size(); ++i) mp.push_back(static_cast<uint16_t>(d->print_of(false, i)));
    for (size_t i = 0; i < d->lrig.size(); ++i) lp.push_back(static_cast<uint16_t>(d->print_of(true, i)));
    wx_add_deck_prints(duel_, static_cast<uint8_t>(seat++), d->main.data(), mp.data(), d->main.size(), d->lrig.data(),
                       lp.data(), d->lrig.size());
  }
  wx_start(duel_);
  advance();
  return true;
}

int Game::zone(uint8_t owner, const std::string& name) const {
  for (const auto& z : zones_)
    if (z.owner == owner && z.name == name) return z.id;
  return -1;
}

wx_card_info Game::card(int view, uint32_t handle) {
  wx_card_info info{};
  if (remote_) view = seat_;
  if (view < 3) {
    if (const wx_card_info* c = model_[view].card(handle)) info = *c;
  } else if (duel_) {
    wx_query_card(duel_, static_cast<uint8_t>(view), handle, &info);  // 전부 보기(리플레이·검사)는 코어에 직접
  }
  return info;
}

std::vector<uint32_t> Game::zone_cards(int view, int zone) {
  if (zone < 0) return {};
  if (remote_) view = seat_;
  if (view < 3) return model_[view].zone(static_cast<uint16_t>(zone));
  std::vector<uint32_t> out;
  if (!duel_) return out;
  out.resize(wx_query_zone(duel_, static_cast<uint8_t>(view), static_cast<uint16_t>(zone), nullptr, 0));
  wx_query_zone(duel_, static_cast<uint8_t>(view), static_cast<uint16_t>(zone), out.data(), out.size());
  return out;
}

std::string Game::card_label(int view, uint32_t handle) {
  const wx_card_info info = card(view, handle);
  if (!info.known) return "(뒷면)";
  return db_.text_of(info.cid).name;
}

void Game::advance() {
  if (!duel_) return;
  for (int i = 0; i < 100000; ++i) {
    const int r = wx_process(duel_);
    pull();
    if (r == WX_END) {
      ended_ = true;
      req_.reset();
      return;
    }
    if (r == WX_NEED_RESPONSE) return;
  }
}

bool Game::respond(const std::vector<uint32_t>& picks) {
  fx_mute_ = false;
  if (remote_) {
    if (!req_ || awaiting_ || !send_) return false;
    send_(picks, false);
    awaiting_ = true;  // 방장의 답(다음 메시지 또는 RETRY)을 기다린다
    return true;
  }
  if (!duel_ || !req_) return false;
  const int r = wx_set_response(duel_, picks.data(), picks.size());
  if (r == WX_OK) {
    for (auto& s : retry_) s.clear();
    req_.reset();
    advance();
    return true;
  }
  pull();  // RETRY 메시지
  return false;
}

bool Game::cancel() {
  if (remote_) {
    if (!req_ || awaiting_ || !send_) return false;
    send_({}, true);
    awaiting_ = true;
    return true;
  }
  if (!duel_ || wx_cancel(duel_) != WX_OK) return false;
  req_.reset();
  advance();
  return true;
}

bool Game::undo() {
  if (remote_ || !duel_ || wx_test_undo(duel_) != WX_OK) return false;
  req_.reset();
  ended_ = false;
  advance();
  return true;
}

void Game::pull() {
  for (uint8_t v = 0; v < 4; ++v) {
    std::vector<uint8_t> buf(wx_get_messages(duel_, v, nullptr, 0));
    wx_get_messages(duel_, v, buf.data(), buf.size());
    size_t pos = 0;
    while (pos + 6 <= buf.size()) {
      Reader rd{buf.data() + pos, buf.size() - pos};
      const size_t len = 4 + rd.get(4);
      if (v < 3 && on_message) on_message(v, buf.data() + pos, len);
      handle(v, buf.data() + pos, len);
      pos += len;
    }
    if (log_[v].size() > 2000) log_[v].erase(log_[v].begin(), log_[v].begin() + 500);
    // 메시지로 모르는 값(효과 반영 수치, 덱 속 순서 등)은 코어를 조회해 보충한다(EDOPro의 MSG_UPDATE_DATA)
    if (v < 3 && duel_ && !model_[v].zones().empty()) {
      std::vector<uint16_t> fixes;
      const std::vector<uint8_t> upd = model_[v].make_update(duel_, v, &fixes);
      if (!upd.empty()) {
        model_[v].apply(upd.data(), upd.size());
        if (on_message) on_message(v, upd.data(), upd.size());
      }
      for (uint16_t z : fixes)
        if (z < model_[v].zones().size()) ++zone_fixes_[model_[v].zones()[z].name];
    }
  }
  if (zones_.size() != model_[0].zones().size()) zones_ = model_[0].zones();
}

// 메시지 하나: 장 모델, 요청, 다시 고르기, 승패, 로그
void Game::handle(int v, const uint8_t* m, size_t len) {
  Reader rd{m, len, 4};
  const uint32_t type = rd.get(2);
  if (remote_ && awaiting_) {
    // 보낸 응답이 받아들여졌으면 다음 메시지가 오고, 거부됐으면 RETRY가 온다
    if (type == WX_MSG_RETRY) awaiting_ = false;
    else {
      awaiting_ = false;
      req_.reset();
      for (auto& s : retry_) s.clear();
    }
  }
  if (v < 3) model_[v].apply(m, len);  // 로그를 만들기 전에 장 모델부터
  if (type == WX_MSG_RESET) {
    fx_[v].clear();
    fx_mute_ = true;
  } else if (!fx_mute_ && type == WX_MSG_START) {
    FxEvent f;
    f.kind = FxEvent::FirstPlayer;
    f.who = m[6];
    fx_[v].push_back(f);
  } else if (!fx_mute_ && type == WX_MSG_TRIGGER) {
    Reader r{m, len, 6};
    FxEvent f;
    f.who = static_cast<int>(r.get(1));
    f.handle = r.get(4);
    f.desc = r.get(4);
    f.cid = card(v, f.handle).cid;
    fx_[v].push_back(f);
  }
  if (type == WX_MSG_RESET) {
    log_[v].clear();
    LogLine l;
    l.kind = LogLine::System;
    l.text = "── 되돌리기 ──";
    log_[v].push_back(std::move(l));
  } else if (type == WX_MSG_REQUEST) {
    // 혼자 하기는 전부 보기 뷰의 요청을, 게스트는 자기 뷰로 온 요청을 쓴다
    if ((!remote_ && v == WX_VIEW_ALL) || (remote_ && v == seat_)) parse_request(m, len);
  } else if (type == WX_MSG_WAITING) {
    if (remote_) req_.reset();
  } else if (type == WX_MSG_RETRY) {
    Reader r{m, len, 6};
    r.get(1);
    const uint32_t n = r.get(2);
    retry_[v].assign(reinterpret_cast<const char*>(m + r.pos), std::min<size_t>(n, len - r.pos));
  } else if (type == WX_MSG_WIN) {
    ended_ = true;
    winner_ = m[6];
    if (remote_) req_.reset();
    LogLine l;
    l.kind = LogLine::System;
    l.who = winner_;
    l.text = "■ 승리";
    log_[v].push_back(std::move(l));
  } else if (type != kMsgUpdate) {
    add_log(v, describe(v, m, len));
  }
}

void Game::parse_request(const uint8_t* m, size_t len) {
  Reader r{m, len, 6};
  Request q;
  q.type = static_cast<uint8_t>(r.get(1));
  q.player = static_cast<uint8_t>(r.get(1));
  q.hint = r.get(4);
  q.min = r.get(4);
  q.max = r.get(4);
  const uint32_t n = r.get(2);
  for (uint32_t i = 0; i < n; ++i) {
    ReqOption o;
    if (q.type == WX_REQ_SELECT_ACTION) {
      o.value = i;
      o.kind = static_cast<uint8_t>(r.get(1));
      o.handle = r.get(4);
      o.zone = static_cast<uint16_t>(r.get(2));
      o.effect = r.get(4);
      o.desc = r.get(4);
    } else if (q.type == WX_REQ_SELECT_CARDS) {
      o.value = o.handle = r.get(4);
    } else {
      o.value = r.get(4);
      o.handle = r.get(4);
      o.desc = r.get(4);
    }
    q.options.push_back(o);
  }
  q.cancelable = r.get(1) != 0;
  q.source = r.get(4);
  q.source_desc = r.get(4);
  req_ = std::move(q);
}

void Game::add_log(int view, LogLine line) {
  if (line.text.empty()) return;
  auto& log = log_[view];
  // 같은 쪽의 같은 일이 카드를 모른 채 이어지면 묶는다(라이프 클로스 7장, 리프레시 등)
  if (!log.empty() && line.kind == LogLine::Normal && line.cid == 0) {
    LogLine& last = log.back();
    if (last.kind == LogLine::Normal && last.cid == 0 && last.desc == line.desc && last.who == line.who &&
        last.text == line.text) {
      ++last.count;
      return;
    }
  }
  log.push_back(std::move(line));
}

// 로그 한 줄. 그 뷰가 받은 메시지라 모르는 카드는 이미 가려져 있다
LogLine Game::describe(int view, const uint8_t* m, size_t len) {
  Reader r{m, len, 4};
  const uint32_t type = r.get(2);
  LogLine l;
  auto zlabel = [&](uint32_t z) -> std::string { return z < zones_.size() ? zone_label(zones_[z].name) : "?"; };
  auto zname = [&](uint32_t z) -> std::string { return z < zones_.size() ? zones_[z].name : ""; };
  auto zowner = [&](uint32_t z) { return z < zones_.size() ? static_cast<int>(zones_[z].owner) : -1; };
  // handle로 지금 이 뷰가 아는 카드(모르면 0)
  auto cid_of = [&](uint32_t handle) { return card(view, handle).cid; };
  auto cname = [&](uint32_t cid) -> std::string { return cid ? db_.text_of(cid).name : "카드"; };
  switch (type) {
    case WX_MSG_NEW_TURN: {
      l.kind = LogLine::Turn;
      l.who = static_cast<int>(r.get(1));
      l.text = std::to_string(r.get(4)) + "턴";
      return l;
    }
    case WX_MSG_START:
      l.kind = LogLine::System;
      l.who = static_cast<int>(r.get(1));
      l.text = "코인토스: 선공";
      return l;
    case WX_MSG_NEW_PHASE:
      l.kind = LogLine::Phase;
      l.text = phase_name(r.get(4));
      return l;
    case WX_MSG_MOVE: {
      r.get(4);
      r.get(4);
      const uint32_t cid = r.get(4), from = r.get(2), to = r.get(2);
      if (from == 0xFFFF) return l;  // 덱을 만들 때의 생성은 로그에 넣지 않는다
      const std::string f = zname(from), t = zname(to);
      // 체크 존을 거쳐 치우는 이동(스펠 처리 뒤, 크러시 뒤)은 앞 줄로 충분하다
      if (f == "check" && t != "hand") return l;
      l.who = zowner(to) >= 0 ? zowner(to) : zowner(from);
      l.cid = cid;
      if (f == "main_deck" && t == "hand") l.text = "드로";
      else if (f == "main_deck" && t == "life_cloth") l.text = "라이프 클로스에 놓음";
      else if (f == "life_cloth" && t == "check") l.text = "크러시";
      else if (f == "trash" && t == "main_deck") l.text = "리프레시: 트래시 → 덱";
      else if (starts_with(t, "signi") && !starts_with(f, "signi")) l.text = "시그니 배치(" + zlabel(to) + ")";
      else if (starts_with(t, "signi")) l.text = "시그니 이동(" + zlabel(from) + " → " + zlabel(to) + ")";
      else if (f == "lrig_deck" && (t == "lrig_center" || starts_with(t, "lrig_assist"))) l.text = "그로우(" + zlabel(to) + ")";
      else if (f == "lrig_deck" && t == "key") l.text = "키";
      else if (t == "check" && f == "hand") l.text = "스펠 사용";
      else if (t == "check" && f == "lrig_deck") l.text = "아츠 사용";
      else if (t == "check") l.text = "체크 존에(" + zlabel(from) + ")";
      else if (t == "ena" && starts_with(f, "signi")) l.text = "에나로(" + zlabel(from) + ")";
      else if (t == "ena") l.text = "에나 차지(" + zlabel(from) + ")";
      else if (t == "trash" && f == "hand") l.text = "버림";
      else if (t == "trash") l.text = "트래시로(" + zlabel(from) + ")";
      else if (t == "hand") l.text = "패에(" + zlabel(from) + ")";
      else l.text = zlabel(from) + " → " + zlabel(to);
      return l;
    }
    case WX_MSG_SHUFFLE: return l;  // 덱 셔플은 리프레시·서치 줄로 충분하다
    case WX_MSG_ATTACK: {
      const wx_card_info c = card(view, r.get(4));
      l.who = c.controller;
      l.cid = c.cid;
      l.text = "어택";
      return l;
    }
    case WX_MSG_BATTLE: {
      const wx_card_info a = card(view, r.get(4)), d = card(view, r.get(4));
      const int32_t ap = static_cast<int32_t>(r.get(4)), dp = static_cast<int32_t>(r.get(4));
      l.who = a.controller;
      l.cid = a.cid;
      l.text = "배틀: " + cname(a.cid) + " " + std::to_string(ap) + " vs " + cname(d.cid) + " " + std::to_string(dp);
      return l;
    }
    case WX_MSG_DAMAGE:
      l.who = static_cast<int>(r.get(1));
      l.text = "데미지";
      return l;
    case WX_MSG_REFRESH:
      l.who = static_cast<int>(r.get(1));
      l.text = "리프레시";
      return l;
    case WX_MSG_COIN: {
      l.who = static_cast<int>(r.get(1));
      l.text = "코인 " + std::to_string(r.get(1)) + "개";
      return l;
    }
    case WX_MSG_MARKER: {
      const uint32_t z = r.get(2), kind = r.get(1);
      l.who = zowner(z);
      const std::string name = kind == 2 ? "【ウィルス】" : "【ゲート】";
      l.text = name + (r.get(1) ? " 놓음(" : " 치움(") + zlabel(z) + ")";
      return l;
    }
    case WX_MSG_TRIGGER: {
      l.kind = LogLine::Activate;
      l.who = static_cast<int>(r.get(1));
      const wx_card_info c = card(view, r.get(4));
      l.cid = c.cid;
      l.print = std::max<uint16_t>(1, c.print);
      l.desc = r.get(4);
      l.text = "효과 발동";
      return l;
    }
    case WX_MSG_REVEAL: {
      const uint32_t h = r.get(4);
      l.cid = r.get(4);
      if (!l.cid) return l;
      l.who = card(view, h).owner;
      l.text = "공개";
      return l;
    }
    default: return l;
  }
}

const char* hint_name(uint32_t hint) {
  switch (hint) {
    case WX_HINT_MULLIGAN: return "引き直し: 되돌릴 카드를 고른다";
    case WX_HINT_START_LRIG: return "시작 루리그(1장 또는 3장)";
    case WX_HINT_CENTER_LRIG: return "센터 루리그";
    case WX_HINT_ENA_CHARGE: return "에나 페이즈: 에나에 놓을 카드";
    case WX_HINT_GROW: return "그로우할 루리그";
    case WX_HINT_PAY_ENA: return "에나 코스트 지불";
    case WX_HINT_MAIN: return "메인 페이즈";
    case WX_HINT_REMOVE: return "리무브할 시그니";
    case WX_HINT_ATTACK_SIGNI: return "어택할 시그니";
    case WX_HINT_ATTACK_LRIG: return "루리그 어택";
    case WX_HINT_GUARD: return "가드";
    case WX_HINT_DISCARD: return "버릴 카드";
    case WX_HINT_TRIGGER_ORDER: return "트리거 처리 순서";
    case WX_HINT_USE_TRIGGER: return "능력을 발동할까?";
    case WX_HINT_LIFEBURST: return "라이프 버스트를 발동할까?";
    case WX_HINT_RULE_TRASH: return "룰 처리: 트래시에 놓을 시그니";
    case WX_HINT_SCRIPT: return "효과: 할까?";
    case WX_HINT_PRE_ATTACK: return "프리어택 스텝";
    case WX_HINT_DEFENSE: return "디펜스 스텝";
    case WX_HINT_CUTIN: return "스펠 컷인";
    case WX_HINT_TARGET: return "대상";
    case WX_HINT_MODE: return "모드 선택";
    case WX_HINT_SELECT: return "카드 선택";
    case WX_HINT_ZONE: return "존 선택";
    case WX_HINT_EXCEED: return "엑시드: 루리그 아래 카드";
    case WX_HINT_ENCORE: return "앙코르 코스트를 낼까?";
    case WX_HINT_DECLARE: return "숫자 선언";
    case WX_HINT_ORDER: return "순서(고른 순서대로)";
    case WX_HINT_BET: return "ベット할까? (코인을 더 내고 효과를 강하게)";
    default: return "선택";
  }
}

const char* phase_name(uint32_t phase) {
  switch (phase) {
    case WX_PHASE_UP: return "업 페이즈";
    case WX_PHASE_DRAW: return "드로 페이즈";
    case WX_PHASE_ENA: return "에나 페이즈";
    case WX_PHASE_GROW: return "그로우 페이즈";
    case WX_PHASE_MAIN: return "메인 페이즈";
    case WX_PHASE_ATTACK: return "어택 페이즈";
    case WX_PHASE_END: return "엔드 페이즈";
    default: return "";
  }
}

std::string zone_label(const std::string& name) {
  static const std::map<std::string, std::string> m = {
      {"main_deck", "덱"},          {"life_cloth", "라이프"},         {"lrig_deck", "루리그 덱"},
      {"hand", "패"},               {"trash", "트래시"},              {"lrig_trash", "루리그 트래시"},
      {"ena", "에나"},              {"check", "체크"},                {"exclude", "제외"},
      {"lrig_center", "센터"},      {"lrig_assist_left", "어시스트 좌"}, {"lrig_assist_right", "어시스트 우"},
      {"key", "키"},                {"signi_left", "시그니 좌"},      {"signi_center", "시그니 중앙"},
      {"signi_right", "시그니 우"}, {"cheer", "치어"},
  };
  auto it = m.find(name);
  return it != m.end() ? it->second : name;
}

}  // namespace wxframe
