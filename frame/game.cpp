#include "game.h"

#include <cstring>

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

const char* read_script(void*, const char* name, size_t* len) {
  static std::string code;
  if (!wxtest::read_script_file(name, code)) return nullptr;
  *len = code.size();
  return code.c_str();
}

std::vector<std::string>* g_core_log = nullptr;
void on_log(void*, const char* msg) {
  if (g_core_log) g_core_log->push_back(std::string("[코어] ") + msg);
}

}  // namespace

Game::~Game() { reset(); }

void Game::reset() {
  if (duel_) wx_destroy_duel(duel_);
  duel_ = nullptr;
  req_.reset();
}

bool Game::start(const wxtest::DeckFile& p1, const wxtest::DeckFile& p2, uint64_t seed, bool practice,
                 std::string& err) {
  if (duel_) wx_destroy_duel(duel_);
  duel_ = nullptr;
  req_.reset();
  for (auto& l : log_) l.clear();
  for (auto& r : retry_) r.clear();
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
  for (uint16_t z = 0; z < wx_zone_count(duel_); ++z) {
    char name[64];
    uint8_t owner = 0;
    wx_query_zone_info(duel_, z, name, sizeof name, &owner, nullptr);
    zones_.push_back({z, owner, name});
  }
  wx_add_deck(duel_, 0, p1.main.data(), p1.main.size(), p1.lrig.data(), p1.lrig.size());
  wx_add_deck(duel_, 1, p2.main.data(), p2.main.size(), p2.lrig.data(), p2.lrig.size());
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
  if (duel_) wx_query_card(duel_, static_cast<uint8_t>(view), handle, &info);
  return info;
}

std::vector<uint32_t> Game::zone_cards(int view, int zone) {
  std::vector<uint32_t> out;
  if (!duel_ || zone < 0) return out;
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
  if (!duel_ || wx_cancel(duel_) != WX_OK) return false;
  req_.reset();
  advance();
  return true;
}

bool Game::undo() {
  if (!duel_ || wx_test_undo(duel_) != WX_OK) return false;
  req_.reset();
  ended_ = false;
  advance();
  return true;
}

void Game::pull() {
  for (uint8_t v = 0; v < 4; ++v) {
    std::vector<uint8_t> buf(wx_get_messages(duel_, v, nullptr, 0));
    if (buf.empty()) continue;
    wx_get_messages(duel_, v, buf.data(), buf.size());
    size_t pos = 0;
    while (pos + 6 <= buf.size()) {
      Reader rd{buf.data() + pos, buf.size() - pos};
      const uint32_t size = rd.get(4);
      const uint32_t type = rd.get(2);
      const uint8_t* m = buf.data() + pos;
      const size_t len = 4 + size;
      if (type == WX_MSG_RESET) {
        log_[v].clear();
        log_[v].push_back("── 되돌리기 ──");
      } else if (type == WX_MSG_REQUEST) {
        if (v == WX_VIEW_ALL) parse_request(m, len);
      } else if (type == WX_MSG_RETRY) {
        Reader r{m, len, 6};
        r.get(1);
        const uint32_t n = r.get(2);
        retry_[v].assign(reinterpret_cast<const char*>(m + r.pos), std::min<size_t>(n, len - r.pos));
      } else if (type == WX_MSG_WIN) {
        ended_ = true;
        winner_ = m[6];
        log_[v].push_back(std::string("■ 승리: P") + std::to_string(winner_ + 1));
      } else {
        std::string line = describe(v, m, len);
        if (!line.empty()) log_[v].push_back(line);
      }
      pos += len;
    }
    if (log_[v].size() > 2000) log_[v].erase(log_[v].begin(), log_[v].begin() + 500);
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
    } else {
      o.value = r.get(4);
      if (q.type == WX_REQ_SELECT_CARDS) o.handle = o.value;
    }
    q.options.push_back(o);
  }
  q.cancelable = r.get(1) != 0;
  req_ = std::move(q);
}

// 로그 한 줄. 그 뷰가 받은 메시지라 모르는 카드는 이미 가려져 있다
std::string Game::describe(int, const uint8_t* m, size_t len) {
  Reader r{m, len, 4};
  const uint32_t type = r.get(2);
  auto zname = [&](uint32_t z) -> std::string {
    if (z >= zones_.size()) return "?";
    return "P" + std::to_string(zones_[z].owner + 1) + " " + zone_label(zones_[z].name);
  };
  auto cname = [&](uint32_t cid) -> std::string { return cid ? db_.text_of(cid).name : "(뒷면)"; };
  switch (type) {
    case WX_MSG_NEW_TURN: {
      const uint32_t p = r.get(1);
      return "━━ " + std::to_string(r.get(4)) + "턴: P" + std::to_string(p + 1) + " ━━";
    }
    case WX_MSG_NEW_PHASE: return std::string("· ") + phase_name(r.get(4));
    case WX_MSG_MOVE: {
      r.get(4);
      r.get(4);
      const uint32_t cid = r.get(4), from = r.get(2), to = r.get(2);
      if (from == 0xFFFF) return {};  // 덱을 만들 때의 생성은 로그에 넣지 않는다
      return cname(cid) + ": " + zname(from) + " -> " + zname(to);
    }
    case WX_MSG_SHUFFLE: return "셔플: " + zname(r.get(2));
    case WX_MSG_ATTACK: return "어택";
    case WX_MSG_BATTLE: {
      r.get(4);
      r.get(4);
      const int32_t ap = static_cast<int32_t>(r.get(4)), dp = static_cast<int32_t>(r.get(4));
      return "배틀 " + std::to_string(ap) + " vs " + std::to_string(dp);
    }
    case WX_MSG_DAMAGE: return "데미지: P" + std::to_string(r.get(1) + 1);
    case WX_MSG_REFRESH: return "리프레시: P" + std::to_string(r.get(1) + 1);
    case WX_MSG_COIN: {
      const uint32_t p = r.get(1);
      return "코인: P" + std::to_string(p + 1) + " " + std::to_string(r.get(1)) + "장";
    }
    case WX_MSG_MARKER: return "【ゲート】: " + zname(r.get(2));
    case WX_MSG_REVEAL: {
      r.get(4);
      const uint32_t cid = r.get(4);
      return cid ? "공개: " + cname(cid) : std::string();
    }
    default: return {};
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
