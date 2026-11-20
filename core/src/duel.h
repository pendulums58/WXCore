#pragma once
#include <functional>
#include <optional>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "carddata.h"
#include "effect.h"
#include "event.h"
#include "request.h"
#include "state.h"
#include "task.h"

struct lua_State;

namespace wx {

using CardDataFn = std::function<bool(Cid, CardData&)>;
// 스크립트 이름(예: "c123.lua")을 받아 내용을 돌려준다.
using ScriptFn = std::function<bool(const std::string& name, std::string& code)>;
using LogFn = std::function<void(const std::string&)>;

struct DuelConfig {
  uint64_t seed = 0;
  CardDataFn card_data;
  ScriptFn script;
  LogFn log;
  bool test_mode = false;               // 꺼져 있으면 테스트 모드 명령을 거부한다
  bool always_ask = false;              // 할 수 있는 게 없어도 묻기(기본: 있을 때만)
  PlayerId first_player = kNoPlayer;    // kNoPlayer면 코어 PRNG로 정한다
};

struct PlayerState {
  uint32_t refreshes_this_turn = 0;
};

// 대전 종료(패배 확정). 코루틴을 타고 최상위까지 올라간다.
struct GameEnd {
  PlayerId winner;
};
// 효과나 리프레시에 의한 턴 종료(용어집: ターンを終了する)
struct TurnEnd {};
// 확정 전 선택을 취소함. 사용 절차 맨 앞까지 되감는다
struct Canceled {};

// 지금 처리 중인 사용·발동 하나(대상 지정 기록)
struct ActCtx {
  EffectId effect = kNoEffect;
  PlayerId player = kNoPlayer;
  CardIdx card = kNoCard;
  std::vector<std::pair<CardIdx, ObjId>> targets;
  bool cancelable = false;
};

class Duel {
 public:
  explicit Duel(DuelConfig cfg);
  ~Duel();
  Duel(const Duel&) = delete;
  Duel& operator=(const Duel&) = delete;

  State state;
  EffectTable effects;
  PlayerState players[2];

  PlayerId turn_player = 0;
  uint32_t phase = 0;
  uint32_t turn_count = 0;
  PlayerId first_player = 0;

  const CardData& data(Cid cid);
  void log(const std::string& msg) const;
  uint32_t intern(const std::string& s);
  const std::string& str(uint32_t id) const { return strings_[id]; }

  // 카드를 만들고 initial_effect를 돌린다(대전 준비·테스트 모드).
  CardIdx new_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos = Pos::Top);
  // 덱을 넣는다. 시작 전에만.
  void set_deck(PlayerId p, const std::vector<Cid>& main, const std::vector<Cid>& lrig);

  // ── 진행(engine.cpp) ──
  enum class Result { Continue, NeedResponse, End };
  void start();  // 게임 시작 절차부터
  // 테스트 모드: 지금 장 상태 그대로 그 턴의 그 페이즈부터 시작한다.
  bool test_begin(PlayerId tp, uint32_t from_phase, bool first_turn = false);
  Result process();
  const Request* request() const { return pending_req_ ? &*pending_req_ : nullptr; }
  bool respond(Response r, std::string* why = nullptr);
  const std::vector<Action>& actions() const { return actions_; }
  bool ended() const { return ended_; }
  PlayerId winner() const { return winner_; }

  // ── 효과 등록 ──
  void register_effect(EffectId id, CardIdx handler);
  void grant_effect(EffectId id, CardIdx handler);
  void register_player_effect(EffectId id, PlayerId p);
  void delete_effect(EffectId id);

  // ── 효과 조작 ──
  EffectId become_copy(CardIdx c, Cid cid, PlayerId by, uint32_t reset);
  EffectId suppress_opponent_effects(PlayerId by, uint32_t reset);
  void reset_phase(uint32_t phase_bit);

  // ── 카드 이동(이벤트를 일으킨다, trigger.cpp) ──
  void move_card(CardIdx c, ZoneId to, uint32_t reason, PlayerId rp, Pos pos = Pos::Top,
                 EffectId re = kNoEffect);
  void banish(CardIdx c, uint32_t reason, PlayerId rp, EffectId re = kNoEffect);
  uint32_t draw(PlayerId p, uint32_t n, uint32_t reason);
  // 존을 지운다. 안의 카드는 트래시로(WXK03-005 FAQ 1·5·6).
  void remove_zone(ZoneId z, PlayerId rp, EffectId re = kNoEffect);
  void raise(const Event& ev);

  // ── 값 계산(calc.cpp) ──
  Cid text_of(CardIdx c);
  uint8_t color_of(CardIdx c);
  std::vector<uint32_t> classes_of(CardIdx c);
  bool has_class(CardIdx c, const std::string& query);
  int32_t level_of(CardIdx c);
  int32_t limit_of(CardIdx c);
  uint32_t type_of(CardIdx c);
  std::vector<EffectId> abilities_of(CardIdx c);
  int32_t power_raw(CardIdx c);
  int32_t power_of(CardIdx c);

  bool effect_live(const Effect& e) const;
  bool effect_suppressed(const Effect& e);
  uint32_t location_of(CardIdx c) const;

  // ── 장 조회 ──
  CardIdx center_lrig(PlayerId p) const;
  CardIdx occupant(ZoneId z) const;  // 슬롯 존의 카드
  int32_t total_limit(PlayerId p);
  bool limit_cond_ok(CardIdx c, PlayerId p);
  bool can_play_signi(CardIdx c, ZoneId z);
  // 그 타이밍에 쓸 수 있는 아츠·스펠·【起】(설계: 행동 열거)
  std::vector<Action> usable_actions(PlayerId p, uint32_t timing);
  // 위치 범위 안의 카드(존 순서). self/opp는 p 기준
  std::vector<CardIdx> cards_in(PlayerId p, uint32_t self_loc, uint32_t opp_loc);
  std::vector<ActCtx> chain;  // 처리 중인 사용·발동. back()이 지금 것
  CardIdx top_of(ZoneId z) const;

  lua_State* lua() const { return L_; }

  // ── 메시지(message.cpp) ──
  std::vector<uint8_t> take_messages(int view);  // 그 뷰에 쌓인 메시지를 꺼낸다
  size_t message_size(int view) const { return outbox_[view].size(); }
  uint32_t handle(CardIdx c) const;              // 메시지에서 카드를 가리키는 번호(객체 번호)
  void set_flags(CardIdx c, uint32_t flags);
  void msg_retry(PlayerId p, const std::string& why);

  // Lua 코루틴이 선택을 요청할 때 쓴다(script.cpp)
  std::optional<Request> lua_request;
  std::function<int(lua_State*, const Response&)> lua_reply;

 private:
  // calc.cpp
  enum class Calc : uint8_t { Text, Color, Classes, Level, Limit, Abilities, Power };
  struct Guard;
  bool computing(CardIdx c, Calc k) const;
  std::pair<Cid, EffectId> text_source(CardIdx c);
  bool affects(Effect& e, CardIdx c);
  std::vector<Effect*> affecting(CardIdx c, uint32_t code);
  bool ability_active(Effect& e);
  uint64_t time_of(const Effect& e) const;
  int32_t eval_value(Effect& e, CardIdx c);
  std::unordered_set<uint64_t> computing_;

  // engine.cpp
  // co_await ask(req): 요청을 걸어 두고 멈춘다. 검증된 응답과 함께 다시 이어진다.
  struct Ask {
    Duel& d;
    Request req;
    bool await_ready() const noexcept { return false; }
    void await_suspend(std::coroutine_handle<> h) {
      d.pending_req_ = std::move(req);
      d.resume_at_ = h;
      d.msg_request();
    }
    Response await_resume() {
      if (d.response_.cancel) throw Canceled{};
      return std::move(d.response_);
    }
  };
  Ask ask(Request r) { return Ask{*this, std::move(r)}; }
  Task<> game(bool setup, uint32_t from_phase);
  Task<> setup();
  Task<> turn(uint32_t from_phase);
  Task<> up_phase();
  Task<> draw_phase();
  Task<> ena_phase();
  Task<> grow_phase();
  Task<> main_phase();
  Task<> attack_phase();
  Task<> end_phase();
  Task<> forced_turn_end();
  Task<> damage(PlayerId p, uint32_t crush, PlayerId by);
  Task<std::vector<CardIdx>> pay_ena(PlayerId p, const std::string& cost, bool cancelable = false);
  // 아츠·스펠·【起】 사용(faq.txt 「スペルの使用手順」「アーツの使用手順」). 취소되면 false
  Task<bool> use(Action a);
  // 프리어택·디펜스 스텝, 스펠 컷인처럼 쓸 게 있으면 묻는 창
  Task<> use_window(PlayerId p, uint32_t timing, uint32_t hint);
  bool can_use(const Action& a);
  // 룰 처리 → 트리거를 더 할 게 없을 때까지(설계: 진행과 타이밍)
  Task<> resolve();
  Task<> resolve_trigger(Pending t);
  Task<bool> rule_processing();  // rules.cpp. 하나라도 처리했으면 true

  // trigger.cpp
  std::vector<EffectId> active_single_triggers(CardIdx c);
  void collect(const Event& ev, const std::vector<EffectId>* pre_single);
  void push_pending(Effect& e, CardIdx handler, const Event& ev);

  // message.cpp
  template <class F>
  void emit(uint16_t type, F&& body);
  template <class F>
  void emit_to(int view, uint16_t type, F&& body);
  void msg_zones();
  void msg_start();
  void msg_turn();
  void enter_phase(uint32_t p);
  void on_move(const MoveRecord& r);
  void on_shuffle(ZoneId z);
  void msg_reveal(CardIdx c);
  void msg_attack(CardIdx c);
  void msg_battle(CardIdx a, CardIdx d, int32_t ap, int32_t dp);
  void msg_player(uint16_t type, PlayerId p);
  void msg_trigger(const Pending& t);
  void msg_request();
  std::vector<uint8_t> outbox_[4];

  // script.cpp
  void init_lua();
  bool load_script(Cid cid);
  void run_initial_effect(CardIdx c, Cid text, EffectId copy_of);
  bool call_filter(int ref, EffectId e, CardIdx c);
  bool call_condition(int ref, EffectId e);
  bool call_trigger_check(int ref, const Pending& t, bool is_target);
  int32_t call_value(int ref, EffectId e, CardIdx c);
  // Lua 함수를 코루틴으로 돌린다. fn_ref == 0이면 __wx_resolve(대상 → 처리)
  Task<> run_lua(int fn_ref, const Pending& t, bool chk);
  void unref(int& ref);

  DuelConfig cfg_;
  lua_State* L_ = nullptr;
  std::unordered_map<Cid, CardData> data_;
  std::unordered_set<Cid> loaded_scripts_;
  std::vector<std::string> strings_;
  std::unordered_map<std::string, uint32_t> string_ids_;

  CardIdx init_card_ = kNoCard;
  Cid init_text_ = 0;
  EffectId init_copy_ = kNoEffect;

  // 진행 상태
  Task<> root_;
  bool started_ = false, ended_ = false;
  PlayerId winner_ = kNoPlayer;
  std::optional<Request> pending_req_;
  std::coroutine_handle<> resume_at_;
  Response response_;
  std::vector<Action> actions_;
  std::vector<Pending> pending_[2];
  std::vector<CardIdx> crushed_;  // 크러시되어 버스트 여부를 기다리는 카드
  bool end_turn_requested_ = false;
  bool grew_this_turn_ = false, removed_this_turn_ = false;
  std::unordered_map<ObjId, int32_t> last_levels_;  // 룰 처리 2의 B 판정용
};

}  // namespace wx
