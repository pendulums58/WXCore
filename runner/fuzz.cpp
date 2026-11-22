// 랜덤 AI 무작위 대전. 요청마다 후보에서 아무거나 골라 끝까지 돌리고, 크래시·무한 루프·응답할 수 없는
// 요청·코어 로그(스크립트 오류 등)·깨진 메시지를 찾는다. 공개 C API만 쓴다(프레임과 같은 길).
#include "fuzz.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iterator>
#include <map>
#include <random>
#include <vector>

#include "card_db.h"
#include "wx_api.h"

namespace wxfuzz {

namespace {

constexpr uint32_t kSigni = 1u << 1, kLrig = 1u << 0, kArts = 1u << 2, kSpell = 1u << 3, kAssist = 1u << 4;
constexpr uint32_t kMain = 1, kAttack = 2, kCutin = 4;
constexpr int kMaxSteps = 200000;  // wx_process 호출 수
constexpr uint32_t kMaxTurns = 400;
constexpr int kMaxRandomTries = 200;
constexpr int kMaxExhaustive = 20000;
bool g_trace = false;  // 요청·응답을 한 줄씩 찍는다(실패한 시드를 볼 때)

void trace(const char* what, const std::vector<uint32_t>& v = {}) {
  if (!g_trace) return;
  std::printf("  %s", what);
  for (uint32_t x : v) std::printf(" %u", x);
  std::printf("\n");
  std::fflush(stdout);
}

// ── 카드 풀 ──

const char* kBanishTarget = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
)";

const char* kDrawActivate = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

const char* kOnPlayDraw = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

const char* kOnPlayMayDraw = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end end)
  c:RegisterEffect(e1)
end
)";

const char* kOppAttackDraw = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()~=tp end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

const char* kLeaveDraw = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

const char* kBurstDraw = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

const char* kKeyword = R"(
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 키워드
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(KEYWORD)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
end
)";

const char* kOnPlayCost = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{C}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=1 end
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end
)";

const char* kOnceFreeze = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
end
)";

const char* kModeLook = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,"look","discard"))
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=Duel.GetDecktopGroup(tp,3)
      Duel.ConfirmCards(tp,g)
      local c=Duel.SelectCards(tp,g:Filter(Card.IsSigni,nil),0,1):GetFirst()
      if c then Duel.PutOnField(c,tp) end
      local rest=Group.CreateGroup()
      for x in g:Iter() do if x~=c then rest:AddCard(x) end end
      Duel.SendToDeckBottom(rest,true)
    else
      local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
      Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
    end
  end)
  c:RegisterEffect(e1)
end
)";

const char* kWhiteAura = R"(
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,c) return c:IsColor(COLOR_WHITE) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
end
)";

struct Def {
  uint32_t type;
  uint8_t color;
  int32_t level, limit, power;
  const char* cost;
  const char* grow;
  bool guard, burst;
  uint32_t timing;
  const char* script;
};

const std::map<uint32_t, Def>& pool() {
  static const std::map<uint32_t, Def> p = {
      {1, {kLrig, 1, 0, 0, 0, "", "", false, false, 0, nullptr}},
      {2, {kLrig, 1, 1, 3, 0, "", "", false, false, 0, nullptr}},
      {3, {kLrig, 1, 2, 5, 0, "", "{W}", false, false, 0, nullptr}},
      {4, {kLrig, 1, 3, 7, 0, "", "{W}{C}", false, false, 0, nullptr}},
      // 어시스트(디바): 레벨 0 루리그 3장이면 시작할 때 어시스트가 생긴다
      {5, {kLrig, 2, 0, 0, 0, "", "", false, false, 0, nullptr}},
      {6, {kAssist, 2, 1, 0, 0, "", "", false, false, kMain, kOnPlayDraw}},
      {7, {kAssist, 2, 2, 1, 0, "", "{C}", false, false, kMain | kAttack, kOnPlayDraw}},
      {8, {kLrig, 4, 0, 0, 0, "", "", false, false, 0, nullptr}},
      {9, {kAssist, 4, 1, 1, 0, "", "", false, false, kAttack, kOnPlayMayDraw}},
      {10, {kArts, 1, 0, 0, 0, "{W}", "", false, false, kMain | kAttack, kDrawActivate}},
      {11, {kArts, 1, 0, 0, 0, "{W}{C}", "", false, false, kAttack | kCutin, kBanishTarget}},
      {100, {kSigni, 1, 1, 0, 3000, "", "", false, false, 0, nullptr}},
      {101, {kSigni, 1, 2, 0, 5000, "", "", false, false, 0, nullptr}},
      {102, {kSigni, 1, 3, 0, 8000, "", "", false, false, 0, nullptr}},
      {103, {kSigni, 1, 1, 0, 1000, "", "", true, false, 0, nullptr}},
      {104, {kSigni, 1, 1, 0, 2000, "", "", false, true, 0, kBurstDraw}},
      {105, {kSigni, 2, 2, 0, 5000, "", "", false, false, 0, nullptr}},
      {106, {kSigni, 1, 1, 0, 2000, "", "", false, false, 0, kOnPlayDraw}},
      {107, {kSigni, 4, 2, 0, 3000, "", "", false, true, 0, kOnPlayMayDraw}},
      {108, {kSigni, 1, 2, 0, 4000, "", "", true, false, 0, kOppAttackDraw}},
      {109, {kSigni, 1, 1, 0, 1000, "", "", false, false, 0, kLeaveDraw}},
      {110, {kSigni, 1, 2, 0, 2000, "", "", false, false, 0, kWhiteAura}},
      {111, {kSigni, 2, 2, 0, 6000, "", "", false, false, 0, nullptr}},  // KEYWORD = 【ランサー】
      {112, {kSigni, 2, 3, 0, 7000, "", "", false, false, 0, nullptr}},  // 【ダブルクラッシュ】
      {113, {kSigni, 4, 1, 0, 1000, "", "", false, false, 0, nullptr}},  // 【アサシン】
      {114, {kSigni, 1, 2, 0, 4000, "", "", false, true, 0, kOnPlayCost}},
      {115, {kSigni, 4, 2, 0, 3000, "", "", false, false, 0, kOnceFreeze}},
      {202, {kSpell, 4, 0, 0, 0, "{U}", "", false, false, 0, kModeLook}},
      {200, {kSpell, 1, 0, 0, 0, "{W}", "", false, true, 0, kBanishTarget}},
      {201, {kSpell, 2, 0, 0, 0, "", "", false, false, 0, kDrawActivate}},
  };
  return p;
}

int read_card(void*, uint32_t cid, wx_card_data* out) {
  auto it = pool().find(cid);
  if (it == pool().end()) return 0;
  const Def& d = it->second;
  // 루리그 타입: 1~4 タマ, 5~7 ユヅキ, 8~9 ウリス
  const char* lrig_types = cid >= 8 && cid <= 9 ? "ウリス" : cid >= 5 && cid <= 7 ? "ユヅキ" : "タマ";
  out->cid = cid;
  out->type = d.type;
  out->color = d.color;
  out->level = d.level;
  out->limit = d.limit;
  out->power = d.power;
  out->classes = d.type & (kLrig | kAssist) ? lrig_types : "";
  out->cost_ena = d.cost;
  out->grow_ena = d.grow;
  out->guard = d.guard;
  out->life_burst = d.burst;
  out->timing = d.timing;
  return 1;
}

const char* read_script(void*, const char* name, size_t* len) {
  if (name[0] != 'c') return nullptr;
  const uint32_t cid = static_cast<uint32_t>(std::strtoul(name + 1, nullptr, 10));
  // 키워드 시그니는 같은 틀에 코드만 바꾼다
  static std::map<uint32_t, std::string> keyword_scripts;
  static const std::map<uint32_t, const char*> keywords = {
      {111, "EFFECT_LANCER"}, {112, "EFFECT_DOUBLE_CRUSH"}, {113, "EFFECT_ASSASSIN"}};
  if (auto k = keywords.find(cid); k != keywords.end()) {
    std::string& s = keyword_scripts[cid];
    if (s.empty()) {
      s = kKeyword;
      s.replace(s.find("KEYWORD"), 7, k->second);
    }
    *len = s.size();
    return s.c_str();
  }
  auto it = pool().find(cid);
  if (it == pool().end() || !it->second.script) return nullptr;
  *len = std::strlen(it->second.script);
  return it->second.script;
}

// ── 실제 DB ──

wxtest::CardDb& real_db() {
  static wxtest::CardDb db;
  if (!db.is_open()) db.open(wxtest::data_dir() + "/wixoss.db");
  return db;
}

int read_real_card(void*, uint32_t cid, wx_card_data* out) { return real_db().fill(cid, out) ? 1 : 0; }

const char* read_real_script(void*, const char* name, size_t* len) {
  static std::string code;
  if (!wxtest::read_script_file(name, code)) return nullptr;
  *len = code.size();
  return code.c_str();
}

void on_log(void* user, const char* msg) { static_cast<std::vector<std::string>*>(user)->push_back(msg); }

// ── 메시지 ──

struct Reader {
  const uint8_t* p;
  size_t n, pos = 0;
  bool bad = false;
  uint32_t get(int bytes) {
    if (pos + bytes > n) {
      bad = true;
      return 0;
    }
    uint32_t v = 0;
    for (int i = 0; i < bytes; ++i) v |= static_cast<uint32_t>(p[pos++]) << (8 * i);
    return v;
  }
};

struct Req {
  uint8_t type = 0, player = 0;
  uint32_t hint = 0, min = 0, max = 0;
  std::vector<uint32_t> options;  // SELECT_CARDS면 handle, SELECT_ACTION이면 0..n-1, 그 외 값
  bool cancelable = false;
};

bool parse_request(const uint8_t* m, size_t len, Req& r) {
  Reader rd{m, len};
  rd.get(4);
  rd.get(2);
  r.type = static_cast<uint8_t>(rd.get(1));
  r.player = static_cast<uint8_t>(rd.get(1));
  r.hint = rd.get(4);
  r.min = rd.get(4);
  r.max = rd.get(4);
  const uint32_t n = rd.get(2);
  r.options.clear();
  for (uint32_t i = 0; i < n; ++i) {
    if (r.type == WX_REQ_SELECT_ACTION) {
      rd.get(1);
      rd.get(4);
      rd.get(2);
      rd.get(4);
      rd.get(4);
      r.options.push_back(i);
    } else {
      r.options.push_back(rd.get(4));
      if (r.type != WX_REQ_SELECT_CARDS) {
        rd.get(4);
        rd.get(4);
      }
    }
  }
  r.cancelable = rd.get(1) != 0;
  rd.get(4);
  rd.get(4);
  return !rd.bad && rd.pos == len;
}

struct Game {
  wx_duel* duel = nullptr;
  std::vector<std::string> logs;
  std::vector<uint8_t>* all_view = nullptr;
  Req req;
  bool has_req = false, won = false, reset_seen = false;
  uint8_t winner = 0;
  uint32_t turns = 0;
  std::string error;

  // 모든 뷰의 메시지를 꺼내 형식을 검사한다. 요청과 진행 상황은 전부 뷰에서 읽는다
  void pull() {
    for (uint8_t v = 0; v < 4; ++v) {
      std::vector<uint8_t> buf(wx_get_messages(duel, v, nullptr, 0));
      if (buf.empty()) continue;
      wx_get_messages(duel, v, buf.data(), buf.size());
      if (v == WX_VIEW_ALL && all_view) all_view->insert(all_view->end(), buf.begin(), buf.end());
      size_t pos = 0;
      while (pos < buf.size()) {
        Reader rd{buf.data() + pos, buf.size() - pos};
        const uint32_t size = rd.get(4);
        const uint32_t type = rd.get(2);
        if (rd.bad || size < 2 || pos + 4 + size > buf.size()) {
          error = "깨진 메시지(뷰 " + std::to_string(v) + ")";
          return;
        }
        const uint8_t* m = buf.data() + pos;
        char line[512];
        wx_dump_message(m, 4 + size, line, sizeof line);
        if (std::strncmp(line, "UNKNOWN", 7) == 0) error = std::string("모르는 메시지: ") + line;
        if (v == WX_VIEW_ALL) {
          if (g_trace) trace(line);
          if (type == WX_MSG_RESET) {
            reset_seen = true;
            turns = 0;
            won = false;
          } else if (type == WX_MSG_NEW_TURN) {
            ++turns;
          } else if (type == WX_MSG_WIN) {
            won = true;
            winner = m[6];
          } else if (type == WX_MSG_REQUEST) {
            has_req = parse_request(m, 4 + size, req);
            if (!has_req) error = std::string("요청 메시지 길이가 안 맞음: ") + line;
          }
        } else if (type == WX_MSG_REQUEST && v <= WX_VIEW_P2 && m[7] != v) {
          error = "다른 플레이어의 요청이 그 뷰로 감";
        }
        pos += 4 + size;
      }
    }
  }
};

std::vector<uint32_t> random_deck(std::mt19937_64& rng) {
  std::vector<uint32_t> signi;
  for (const auto& [cid, d] : pool())
    if (d.type == kSigni || d.type == kSpell) signi.push_back(cid);
  std::vector<uint32_t> main;
  for (int i = 0; i < 40; ++i) main.push_back(signi[rng() % signi.size()]);
  return main;
}

// 고를 개수와 후보를 무작위로
std::vector<uint32_t> random_picks(const Req& r, std::mt19937_64& rng) {
  if (r.type == WX_REQ_YES_NO) return {static_cast<uint32_t>(rng() % 2)};
  const uint32_t hi = std::min<uint32_t>(r.max, static_cast<uint32_t>(r.options.size()));
  const uint32_t lo = std::min(r.min, hi);
  const uint32_t k = lo + static_cast<uint32_t>(rng() % (hi - lo + 1));
  std::vector<uint32_t> opts = r.options;
  std::shuffle(opts.begin(), opts.end(), rng);
  opts.resize(k);
  return opts;
}

// 무작위로 안 되면 개수 작은 것부터 조합을 전부 시도한다(에나 지불처럼 검증이 까다로운 요청)
bool exhaustive(Game& g, const Req& r) {
  const uint32_t n = static_cast<uint32_t>(r.options.size());
  int tries = 0;
  for (uint32_t k = r.min; k <= std::min(r.max, n); ++k) {
    std::vector<bool> sel(n, false);
    std::fill(sel.begin(), sel.begin() + k, true);
    do {
      std::vector<uint32_t> picks;
      for (uint32_t i = 0; i < n; ++i)
        if (sel[i]) picks.push_back(r.options[i]);
      if (wx_set_response(g.duel, picks.data(), picks.size()) == WX_OK) return true;
      if (++tries > kMaxExhaustive) return false;
    } while (std::prev_permutation(sel.begin(), sel.end()));
  }
  return false;
}

}  // namespace

bool play(uint64_t seed, bool undo, std::string& why, Summary& sum, std::vector<uint8_t>* all_view,
          const std::string& deck_name, const std::string& deck2_name) {
  wxtest::DeckFile deck[2];
  if (!deck_name.empty()) {
    const std::string names[2] = {deck_name, deck2_name.empty() ? deck_name : deck2_name};
    for (int p = 0; p < 2; ++p) {
      std::string error;
      if (!real_db().is_open() ||
          !wxtest::load_deck(wxtest::data_dir() + "/decks/" + names[p] + ".json", real_db(), deck[p], error)) {
        why = error.empty() ? "카드 DB를 못 열었음" : error;
        return false;
      }
    }
  }
  std::mt19937_64 rng(seed * 0x9E3779B97F4A7C15ull + 1);
  Game g;
  g.all_view = all_view;
  wx_duel_options o{};
  o.schema_version = WX_SCHEMA_VERSION;
  o.seed = seed;
  o.flags = undo ? WX_FLAG_TEST_MODE : 0;
  o.first_player = 0xFF;
  o.card_reader = deck_name.empty() ? read_card : read_real_card;
  o.script_reader = deck_name.empty() ? read_script : read_real_script;
  o.log_handler = on_log;
  o.user = &g.logs;
  if (wx_create_duel(&o, &g.duel) != WX_OK) {
    why = "대전 생성 실패";
    return false;
  }
  struct Destroy {
    wx_duel* d;
    ~Destroy() { wx_destroy_duel(d); }
  } destroy{g.duel};

  const uint32_t lrig[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
  for (uint8_t p = 0; p < 2; ++p) {
    if (!deck_name.empty()) {
      wx_add_deck(g.duel, p, deck[p].main.data(), deck[p].main.size(), deck[p].lrig.data(), deck[p].lrig.size());
      continue;
    }
    const auto main = random_deck(rng);
    wx_add_deck(g.duel, p, main.data(), main.size(), lrig, std::size(lrig));
  }
  wx_start(g.duel);

  int undos_left = 20;
  for (int step = 0; step < kMaxSteps; ++step) {
    int r = WX_END;
    try {
      r = wx_process(g.duel);
    } catch (const std::exception& e) {
      why = std::string("예외: ") + e.what();
      return false;
    } catch (...) {
      why = "알 수 없는 예외";
      return false;
    }
    g.pull();
    if (!g.error.empty()) {
      why = g.error;
      return false;
    }
    if (!g.logs.empty()) {
      why = "코어 로그: " + g.logs.front();
      return false;
    }
    if (g.turns > kMaxTurns) {
      why = "끝나지 않음(" + std::to_string(kMaxTurns) + "턴 초과)";
      return false;
    }
    if (r == WX_END) {
      if (!g.won) {
        why = "WIN 없이 끝남";
        return false;
      }
      ++sum.wins[g.winner & 1];
      sum.turns += g.turns;
      return true;
    }
    if (r != WX_NEED_RESPONSE) continue;
    if (!g.has_req) {
      why = "NEED_RESPONSE인데 요청 메시지가 없음";
      return false;
    }
    const Req req = g.req;

    if (undo && undos_left > 0 && rng() % 50 == 0) {
      g.reset_seen = false;
      trace("-> undo");
      const int u = wx_test_undo(g.duel);
      if (u == WX_OK) {
        --undos_left;
        ++sum.undos;
        g.pull();
        if (!g.reset_seen) {
          why = "되돌렸는데 RESET이 없음";
          return false;
        }
        continue;
      }
      if (u != WX_ERR_STATE) {
        why = "wx_test_undo 실패 " + std::to_string(u);
        return false;
      }
    }

    // 확정 전 선택은 가끔 취소해 본다
    if (req.cancelable && rng() % 20 == 0) {
      trace("-> cancel");
      if (wx_cancel(g.duel) != WX_OK) {
        why = "cancelable인데 취소 거부";
        return false;
      }
      g.has_req = false;
      ++sum.responses;
      continue;
    }
    bool done = false;
    for (int t = 0; t < kMaxRandomTries && !done; ++t) {
      const auto picks = random_picks(req, rng);
      done = wx_set_response(g.duel, picks.data(), picks.size()) == WX_OK;
      if (done) trace("-> answer", picks);
    }
    if (!done) done = exhaustive(g, req);
    if (!done && req.cancelable) done = wx_cancel(g.duel) == WX_OK;
    if (!done) {
      why = "응답할 수 없는 요청(hint " + std::to_string(req.hint) + ", 후보 " + std::to_string(req.options.size()) +
            ", " + std::to_string(req.min) + ".." + std::to_string(req.max) + ")";
      return false;
    }
    g.has_req = false;  // 다음 요청 메시지를 기다린다
    ++sum.responses;
  }
  why = "진행 단계 한도 초과(무한 루프?)";
  return false;
}

Summary run(const Options& opt) {
  g_trace = opt.trace;
  Summary sum;
  for (int i = 0; i < opt.games; ++i) {
    const uint64_t seed = opt.seed + static_cast<uint64_t>(i);
    if (opt.verbose) {
      std::printf("seed %llu ...\n", static_cast<unsigned long long>(seed));
      std::fflush(stdout);  // 크래시하면 마지막 시드가 남는다
    }
    std::string why;
    ++sum.games;
    if (!play(seed, opt.undo, why, sum, nullptr, opt.deck, opt.deck2)) {
      ++sum.failed;
      std::printf("FAIL fuzz seed %llu: %s\n", static_cast<unsigned long long>(seed), why.c_str());
    }
  }
  return sum;
}

}  // namespace wxfuzz
