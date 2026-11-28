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
  bool reset_message = false;           // 만들 때 MSG_RESET부터 보낸다(되돌리기 재실행)
};

struct PlayerState {
  // 센터 루리그가 타고 있는 시그니(乗る). 턴 종료 시까지. 장을 떠난 것은 남아 있어도 세지 않는다(용어집: ドライブ状態)
  std::vector<std::pair<CardIdx, ObjId>> rides;
  uint32_t refreshes_this_turn = 0;
  uint32_t coins = 0;  // 용어집: コイン. 시작 0장, 상한 5장
  uint32_t subscribers = 0;  // 용어집: 登録者数. 만 명 단위, 상한 없음
  uint32_t discarded_this_turn = 0;    // 이 턴에 버린 패(룰·코스트·출현 조건 포함. WD16-014 FAQ 1)
  uint32_t drawn_attack_this_turn = 0;  // 이 턴의 어택 페이즈에 뽑은 장수
  uint32_t crushed_this_turn = 0;      // 이 턴에 크러시된 자기 라이프 클로스 수
  uint32_t extra_turns = 0;            // 「このターンの次に、追加の１ターンを得る」
  uint32_t skip_turns = 0;             // 건너뛸 다음 턴 수(「次のあなたのターンをスキップする」)
  uint32_t arts_used_this_turn = 0;    // 이 턴에 쓴 아츠 수(WD15-006)
  uint32_t spells_used_this_turn = 0;  // 이 턴에 쓴 스펠 수(WX09-018)
  // 이 턴에 상대 효과로 옮겨진 것(PR-463): 1 장의 시그니가 떠남, 2 에나에서 트래시, 4 패에서 트래시
  uint8_t moved_by_opp_this_turn = 0;
  uint32_t banished_this_turn = 0;     // 이 턴에 바니시된 이 플레이어의 시그니 수(WX13-026)
  uint32_t opp_to_deck_this_turn = 0;  // 이 턴에 이 플레이어의 효과로 상대 카드가 덱으로 옮겨진 장수(WDK09-014)
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
  bool negated = false;  // 효과가 打ち消され었다(스펠)
  bool no_negate = false;  // 상대의 효과로 打ち消されない(EFFECT_NO_NEGATE)
  std::vector<CardIdx> paid;  // 사용 코스트로 낸 에나(WX04-063)
  EffectId bounce = kNoEffect;  // 打ち消し한 효과가 「トラッシュから手札に戻す」면 그 효과
  PlayerId recast = 2;          // 「その後、あなたはそれをトラッシュから…コストを支払わずに限定条件を無視して使用してもよい」(WX07-014)의 플레이어
  bool bet = false;  // ベット했다(Duel.IsBet)
  CardIdx event_source = kNoCard;  // 트리거한 사건을 일으킨 시그니(Duel.GetBanisher·GetCrusher)
  std::string base_cost;  // 카드 밖의 감소까지 뺀 사용 코스트(Duel.GetUseCost)
  std::optional<std::string> use_cost;  // 선언 때 정한 사용 코스트(Duel.SetUseCost)
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
  CardIdx new_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos = Pos::Top, uint16_t print = 1);
  // 덱을 넣는다. 시작 전에만.
  // prints: 장마다 판본(짧거나 비면 1)
  void set_deck(PlayerId p, const std::vector<Cid>& main, const std::vector<Cid>& lrig,
                const std::vector<uint16_t>& main_prints = {}, const std::vector<uint16_t>& lrig_prints = {});

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
  bool started() const { return started_; }
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
  // 옮겼으면 true. 「効果を受けない」 시그니는 효과로 시그니 존을 떠나지 않는다(false)
  bool move_card(CardIdx c, ZoneId to, uint32_t reason, PlayerId rp, Pos pos = Pos::Top,
                 EffectId re = kNoEffect);
  // 바니시했으면 true. 「バニッシュされない」면 아무것도 하지 않는다
  // by: 배틀로 바니시한 시그니. 효과면 re의 시그니(장에 있을 때)가 바니시한 시그니다
  bool banish(CardIdx c, uint32_t reason, PlayerId rp, EffectId re = kNoEffect, CardIdx by = kNoCard);
  // 지금 트리거를 모으는 바니시를 한 시그니(Duel.GetBanisher). 룰·아츠·스펠·라이프 버스트면 kNoCard
  CardIdx banisher = kNoCard;
  CardIdx crusher = kNoCard;
  CardIdx battler = kNoCard;  // EVENT_BATTLE의 배틀 상대(Duel.GetBattleOpponent)  // 크러시한 시그니·루리그(Duel.GetCrusher)
  bool collecting = false;    // 트리거를 모으는 중(조건 함수)
  bool no_play_trigger = false;  // 지금 놓는 시그니의 【出】은 발동하지 않는다(Duel.PutOnField의 세 번째 값)
  // 血晶武装: from을 host 밑에 놓고 host를 血晶武装状態로(이미 그 상태면 이벤트 없음)
  void blood_arm(CardIdx host, CardIdx from, PlayerId rp);
  bool same_name(CardIdx a, CardIdx b);  // 같은 이름(alias, 없으면 cid. 지금 텍스트 기준)
  uint32_t draw(PlayerId p, uint32_t n, uint32_t reason);
  // 존을 지운다. 안의 카드는 트래시로(WXK03-005 FAQ 1·5·6).
  void remove_zone(ZoneId z, PlayerId rp, EffectId re = kNoEffect);
  void raise(const Event& ev);

  // ── 값 계산(calc.cpp) ──
  Cid text_of(CardIdx c);
  uint8_t color_of(CardIdx c);
  std::vector<uint32_t> classes_of(CardIdx c);  // 클래스 코드(class_code)
  bool has_class(CardIdx c, uint32_t sys, uint32_t race);
  std::vector<uint32_t> lrig_types_of(CardIdx c);
  int32_t level_of(CardIdx c);
  int32_t limit_of(CardIdx c);
  int32_t limit_cost_of(CardIdx c);  // 시그니가 리미트 합계에 더하는 값: 사용 리미트, 없으면 레벨
  uint32_t type_of(CardIdx c);
  std::vector<EffectId> abilities_of(CardIdx c);
  int32_t power_raw(CardIdx c);
  int32_t power_of(CardIdx c);
  bool has_keyword(CardIdx c, uint32_t code);  // EFFECT_LANCER 등

  bool effect_live(const Effect& e) const;
  bool effect_suppressed(const Effect& e);
  uint32_t location_of(CardIdx c) const;

  // ── 장 조회 ──
  CardIdx center_lrig(PlayerId p) const;
  CardIdx occupant(ZoneId z) const;  // 슬롯 존의 카드
  int32_t total_limit(PlayerId p);
  bool limit_cond_ok(CardIdx c, PlayerId p);
  bool can_play_signi(CardIdx c, ZoneId z);
  // 【ライズ】: c를 z의 시그니 위에 낼 수 있는가(ライズ条件). c에 라이즈가 있으면 그런 존에만 낸다
  bool has_rise(CardIdx c) { return effects.seen(EFFECT_RISE) && has_keyword(c, EFFECT_RISE); }
  bool rise_ok(CardIdx c, ZoneId z, PlayerId p);
  bool zone_ok(CardIdx c, ZoneId z, PlayerId p);  // 빈 존(라이즈면 조건에 맞는 시그니가 있는 존), 리미트, 정면 강제
  bool front_ok(PlayerId p, ZoneId z);  // EFFECT_MUST_FRONT
  // 그 존(센터·어시스트)의 루리그 위에 next로 그로우할 수 있는가. 그로우 코스트를 낼 수 있는지까지
  bool can_grow(ZoneId z, CardIdx next);
  // 루리그 3체가 모두 그 팀인가(용어집: チームアイコン). 루리그가 1체뿐이면 거짓
  bool team_ok(PlayerId p, const std::string& team);
  // 에나 지불에 쓰는 색. 【マルチエナ】면 모든 색(용어집: マルチエナ)
  uint8_t pay_color(CardIdx c);
  std::vector<uint8_t> ena_colors(PlayerId p);
  // 【エナチャージＮ】: 덱 위에서 N장을 에나로(용어집: エナチャージ). 옮긴 장수
  std::vector<CardIdx> ena_charge(PlayerId p, uint32_t n, uint32_t reason, PlayerId rp, EffectId re = kNoEffect);
  // 장에 있는 루리그 수(센터 + 어시스트)
  int lrig_count(PlayerId p) const;
  // 다음 선택 요청에 붙일 Lua 검증 함수(g) → bool. Duel.SetSelectCheck가 걸고 요청을 만들 때 가져간다
  int select_check_ref = 0;
  // 라이프 클로스를 위에서 n장 크러시(데미지 아님). 버스트는 룰 처리에서
  void crush(PlayerId p, uint32_t n, PlayerId by, bool damage = false, CardIdx src = kNoCard);
  bool cannot_crush(PlayerId p, bool damage);  // EFFECT_CANNOT_CRUSH
  // 플레이어에게 걸리는 FIELD 효과(SetTargetRange(1,0)=자기, (0,1)=상대)가 지금 적용되는가
  bool player_affected(PlayerId p, uint32_t code) { return player_effect(p, code) != nullptr; }
  Effect* player_effect(PlayerId p, uint32_t code) {
    const auto list = player_effects(p, code);
    return list.empty() ? nullptr : list.front();
  }
  std::vector<Effect*> player_effects(PlayerId p, uint32_t code);
  // 【ライフバースト】を持つか(부여 포함. 용어집: バーストアイコン)
  bool has_burst(CardIdx c) {
    return data(text_of(c)).life_burst || player_affected(state.cards.get(c).owner, EFFECT_GRANT_LIFEBURST);
  }
  // 장의 시그니 c가 효과 src를 받지 않는가(EFFECT_IMMUNE)
  bool immune(CardIdx c, const Effect& src);
  void crushed_to_ena(CardIdx c);      // 크러시된 카드를 에나로(CF_CRUSH_REFILL 대체 포함)
  const std::vector<CardIdx>& crushed_list() const { return crushed_; }
  // 효과로 시그니를 장에 낼 수 있는 존(빈 시그니 존, 레벨·리미트·한정 조건. 용어집: リミット)
  std::vector<ZoneId> signi_zones_for(CardIdx c, PlayerId p);
  // 그 플레이어가 카드를 본다(인지 기록 + 그 뷰에 공개)
  void confirm(PlayerId p, const std::vector<CardIdx>& cards);
  // 공개한다(「公開する」): 두 플레이어가 알게 되고 관전자에게도 보인다
  void reveal(const std::vector<CardIdx>& cards);
  // c를 host의 【アクセ】로 붙인다. 시그니 1체에 1장까지(용어집: アクセ). 붙일 수 없으면 false
  bool attach_acce(CardIdx c, CardIdx host);
  // 【チャーム】으로 붙인다. 「効果を受けない」 시그니에도 붙는다(용어집: チャーム)
  bool attach_charm(CardIdx c, CardIdx host);
  bool attack_negated = false;
  std::vector<CardIdx> no_burst_;  // 「この効果でクラッシュされたカードのライフバーストは発動しない」  // 지금 어택이 무효가 됐다(「そのアタックを無効にする」)
  bool put_key(PlayerId p, CardIdx key, uint32_t reason, EffectId re);  // 키를 키 존에. 있던 키는 루리그 트래시로
  // ドライブ状態(용어집). 센터 루리그는 타고 있는 시그니가 있으면, 시그니는 루리그가 타고 있으면
  bool is_drive(CardIdx c);
  void ride_on(PlayerId p, CardIdx c);  // p의 센터 루리그가 c에 탄다. 다른 시그니에 타고 있었으면 갈아탄다
  // 【トラップ】(용어집: トラップ). 설치 / 표면으로 하고 《トラップアイコン》을 발동시킨다 / 그 능력(없으면 kNoEffect)
  void set_trap(CardIdx c, ZoneId z);
  void set_seed(CardIdx c, ZoneId z);
  // 효과로 그로우한다(코스트 없이, 같은 레벨도 된다. 공통 루리그 타입은 필요). WX03-024
  bool grow_by_effect(PlayerId p, CardIdx next);
  bool grow_cost_zero(PlayerId p, CardIdx next);
  EffectId activate_effect(CardIdx c);
  bool next_attack_negated();
  bool lancer_crush_ = false;  // EVENT_CRUSHED에 REASON_LANCER
  std::unordered_map<CardIdx, std::vector<Cid>> resona_mats_;  // 레조나가 출현 조건으로 트래시에 둔 카드(WX07-009)
  void note_arts_hit(CardIdx c, EffectId re);  // EVENT_ARTS_HIT
  std::vector<CardIdx> down_log_[2];  // 이 턴 메인 페이즈에 다운 상태가 된 카드(같은 카드가 여러 번이면 여러 번). WX05-042  // 카드의 사용 효과(EFFECT_TYPE_ACTIVATE)
  int32_t signi_limit(PlayerId p);       // EFFECT_SIGNI_LIMIT(없으면 3)  // EFFECT_GROW_COST_ZERO
  std::unordered_map<ObjId, bool> power_reached_;  // EFFECT_POWER_WATCH: 지난번에 값 이상이었나
  bool bloom(CardIdx c);  // 【シード】를 개화한다(용어집: 開花する). 같은 존에 시그니가 있으면 false
  void open_trap(CardIdx c);
  EffectId trap_ability(CardIdx c);
  // 이 시그니들을 한꺼번에 낼 수 있는가(빈 존·레벨·리미트·한정 조건. 라이즈는 안 된다)
  bool can_put_all(const std::vector<CardIdx>& cards, PlayerId p);
  bool use_forbidden(PlayerId p, CardIdx c);  // EFFECT_CANNOT_USE_ARTS·EFFECT_CANNOT_USE
  bool banish_immune(CardIdx c, const Effect& src);  // EFFECT_BANISH_IMMUNE
  bool immune_by(CardIdx c, const Effect& src, uint32_t code);
  // 바니시되는 대신 【チャーム】을 트래시에 놓을 수 있는가(EFFECT_CHARM_GUARD). 하면 charm_trash
  std::vector<EffectId> leave_guards(CardIdx c);
  bool has_data(Cid cid);  // 카드 데이터가 있는가
  bool can_charm_guard(CardIdx c, uint32_t reason, EffectId re);
  Request charm_request(CardIdx c);
  void charm_trash(CardIdx c);
  // 코인(용어집: コイン). 상한 5장
  void gain_coin(PlayerId p, int32_t n);
  void gain_subscribers(PlayerId p, uint32_t n);
  void gain_abilities(CardIdx c, Cid cid);
  void restore_zone(ZoneId z);  // 없앤 시그니 존을 되살린다
  // 「それの【自】能力１つを発動させる」(PR-366): 조건을 채운 것으로 그 트리거 능력을 대기열에
  bool fire_trigger(CardIdx c, uint32_t desc);
  PlayerId lose_request = kNoPlayer;  // 「あなたはゲームに敗北する」: 다음 룰 처리에서 진다  // 登録者数를 n만 명 얻는다
  bool pay_coin(PlayerId p, uint32_t n);
  // 【ゲート】를 놓는다. 이미 있으면 false
  bool place_gate(ZoneId z);
  // 【ウィルス】(용어집: ウィルス·感染状態). 이미 있거나 시그니 존이 아니면 놓지 않는다(false)
  bool place_virus(ZoneId z);
  bool remove_virus(ZoneId z, PlayerId by);
  // 서로 크로스 조건으로 이어진 시그니들(자신 포함). 크로스 상태가 아니면 빈 목록(용어집: クロスシグニ).
  // 짝이 능력을 잃어도 한쪽이 조건을 채우면 둘 다 크로스 상태다
  std::vector<CardIdx> cross_group(CardIdx c);
  bool is_cross(CardIdx c) { return !cross_group(c).empty(); }
  bool infected(CardIdx c);  // 【ウィルス】가 있는 시그니 존에 있다
  // 자기 루리그(센터·어시스트) 아래 카드(엑시드 코스트. 용어집: エクシード)
  std::vector<CardIdx> exceed_cards(PlayerId p);
  bool can_play_key(PlayerId p, CardIdx key);
  // 장에 있는 「…を得る」(EFFECT_GRANT) 부여를 대상마다 실제 능력으로 만든다(레이어 3)
  void sync_grants();
  bool grant_source_ok(const Effect& x);
  bool in_sync_ = false;
  // 덱 위에서 n번째에 놓는다. 덱이 n-1장보다 적으면 맨 아래(WDK09-011 FAQ 1)
  void move_to_deck_position(CardIdx c, uint32_t n, uint32_t reason, PlayerId rp, EffectId re);
  int32_t hand_limit(PlayerId p);
  // 이 턴에 어택했는가. 「アタックしているシグニとして」 나온 것은 아니다(WDK06-R09 FAQ 2)
  bool attacked_this_turn(CardIdx c) const { return attacked_.count(state.cards.get(c).oid) != 0; }
  bool can_attack(CardIdx c) {
    // ドライブ状態의 루리그는 어택할 수 없다. 시그니는 할 수 있다
    if ((location_of(c) & LOCATION_LRIG) && is_drive(c)) return false;
    return !has_keyword(c, EFFECT_CANNOT_ATTACK) &&
           !(attacked_.count(state.cards.get(c).oid) && has_keyword(c, EFFECT_ATTACK_ONCE));
  }
  bool has_guard(CardIdx c) { return (data(text_of(c)).guard || has_keyword(c, EFFECT_GUARD_ICON)) && !has_keyword(c, EFFECT_LOSE_GUARD); }
  // 효과 처리 하나가 끝날 때: 그 사이 덱으로 옮겨진 카드로 EVENT_MOVED_TO_DECK을 한 번 낸다
  void flush_deck_moves();
  // 《ターン1回》 등 횟수 제한
  bool count_ok(Effect& e);
  void count_use(Effect& e);
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
  // 「アタックしているシグニとして場に出す」: 지금 어택 대신 배틀·데미지할 시그니(WDK-F03-15 FAQ 2)
  void add_extra_attacker(CardIdx c) { extra_attackers_.push_back({c, state.cards.get(c).oid}); }
  void msg_retry(PlayerId p, const std::string& why);

  // Lua 코루틴이 선택을 요청할 때 쓴다(script.cpp)
  std::optional<Request> lua_request;
  // Lua가 엔진 절차(예: 카드 사용)를 기다릴 때. 결과 bool을 Lua에 돌려준다
  std::function<Task<bool>()> lua_task;
  bool free_use_ = false;
  Task<bool> use_card(Action a) { return use(a); }
  void request_end_turn() { end_turn_requested_ = true; }
  bool enter_down_ = false;  // 「ダウン状態で場に出す」
  void fire_lifeburst(CardIdx c);  // 「そのライフバーストを発動させる」(WX13-032)
  bool extra_turn_now_ = false;  // 지금 턴이 효과로 추가된 턴인가(WX10-026)
  Task<bool> damage_by_effect(PlayerId p, PlayerId by) {
    co_await damage(p, 1, by, kNoCard);
    co_return true;
  }
  bool has_ability(CardIdx c) {
    sync_grants();
    bool any = false;
    effects.for_each([&](Effect& e) { any |= e.handler == c && e.is_ability() && ability_active(e); });
    return any;
  }  // 다음 use()는 코스트를 내지 않는다(「コストを支払わずに使用する」)
  std::function<int(lua_State*, const Response&)> lua_reply;

 private:
  // calc.cpp
  enum class Calc : uint8_t { Text, Color, Classes, Level, Limit, Abilities, Power, Disabled };
  struct Guard;
  bool cross_to(CardIdx c, CardIdx partner, int64_t side);  // c의 크로스 조건이 partner를 짝으로 채우는가
  bool computing(CardIdx c, Calc k) const;
  std::pair<Cid, EffectId> text_source(CardIdx c);
  // 효과의 설명 번호. 붙이지 않은 라이프 버스트는 그 카드의 LB 문장(cid × 32 + 31)
  uint32_t desc_of(EffectId id);
  uint32_t lb_desc(CardIdx c) { return text_of(c) * 32 + 31; }
  bool affects(Effect& e, CardIdx c);
  std::vector<Effect*> affecting(CardIdx c, uint32_t code);
  bool ability_active(Effect& e);
  bool ability_disabled(const Effect& e);  // EFFECT_DISABLE_ABILITY
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
      if (req.source == kNoCard && !d.chain.empty()) {
        req.source = d.chain.back().card;
        if (!req.source_desc) req.source_desc = d.desc_of(d.chain.back().effect);
      }
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
  // 어택한 시그니의 배틀 또는 데미지. neighbor = 정면과 함께 어택하는 옆 존(EFFECT_ATTACK_NEIGHBOR)
  Task<> signi_battle(CardIdx a, PlayerId tp, ZoneId neighbor = kNoZone, ZoneId target = kNoZone);
  // 어택 데미지로 크러시하는 장수. 【ダブルクラッシュ】·【トリプルクラッシュ】는 겹치지 않고 큰 쪽
  uint32_t crush_count(CardIdx a) { return has_keyword(a, EFFECT_TRIPLE_CRUSH) ? 3 : has_keyword(a, EFFECT_DOUBLE_CRUSH) ? 2 : 1; }
  Task<bool> charm_guard(CardIdx c, uint32_t reason);  // 물어보고 대체하면 true
  Task<ZoneId> attack_neighbor(CardIdx a, PlayerId tp);
  Task<ZoneId> attack_zone(CardIdx a, PlayerId tp);  // EFFECT_ATTACK_ZONE: 정면 대신 어택할 존
  Task<> lrig_attack_step(PlayerId tp, PlayerId opp);
  bool cannot_guard(PlayerId p, CardIdx c);
  bool prevent_damage(PlayerId p);  // EFFECT_PREVENT_DAMAGE가 있으면 하나를 쓰고 true     // EFFECT_CANNOT_GUARD
  Task<> end_phase();
  Task<> forced_turn_end();
  void beat_to_trash();  // 【ビート】를 전부 트래시로(턴 끝)
  Task<> damage(PlayerId p, uint32_t n, PlayerId by, CardIdx src = kNoCard);
  Task<std::vector<CardIdx>> pay_ena(PlayerId p, const std::string& cost, bool cancelable = false);
  // 아츠·스펠·【起】 사용(faq.txt 「スペルの使用手順」「アーツの使用手順」). 취소되면 false
  Task<bool> use(Action a);
  // faq.txt 「グロウの手順」. 에나 선택을 취소하면 false
  Effect* grow_proc(CardIdx next);  // EFFECT_GROW_PROC
  Task<bool> grow(PlayerId p, ZoneId z, CardIdx next, bool cancelable);
  // 용어집: キー. 코스트를 내고 키 존에. 이미 키가 있으면 그것을 루리그 트래시에
  Task<bool> play_key(PlayerId p, CardIdx key);
  // 레조나(용어집: レゾナ, 出現条件). 출현 조건 카드를 고르고(취소 가능) 체크 존 → 트래시 → 시그니 존
  Task<bool> play_resona(PlayerId p, CardIdx c, EffectId e);
  std::vector<CardIdx> resona_candidates(CardIdx c, Effect& e);
  bool resona_ok(CardIdx c, Effect& e, const std::vector<CardIdx>& mats, std::string* why = nullptr,
                 const std::vector<CardIdx>* cand = nullptr);
  bool resona_feasible(CardIdx c, Effect& e);
  std::vector<ZoneId> resona_zones(PlayerId p, const std::vector<CardIdx>& leaving);
  int32_t play_value_ = 0;   // 다음에 장에 나오는 카드의 EVENT_ON_PLAY ev(레조나: 출현 조건으로 트래시한 시그니의 레벨 합계)
  bool resona_raw_ = false;  // 레조나를 체크 존에 둘 때 「대신 루리그 덱」을 건너뛴다
  Task<std::vector<CardIdx>> pick_exceed(PlayerId p, uint32_t n, bool cancelable, int check = 0);
  bool exceed_ok(PlayerId p, const Effect& e);  // 엑시드 장수와 「エクシード１（白のカード）」 조건(check_ref)
  // 카드 밖의 「使用コストは…減る」(EFFECT_REDUCE_COST)와 그것을 뺀 사용 코스트
  std::vector<Effect*> cost_reducers(PlayerId p, CardIdx c);
  std::string use_cost(PlayerId p, CardIdx c);
  bool usable_as_ldeck(CardIdx c, PlayerId p);  // EFFECT_USE_AS_LDECK
  std::string ability_cost(PlayerId p, const Effect& e);
  uint32_t coin_cost(const Action& a);
  // 프리어택·디펜스 스텝, 스펠 컷인처럼 쓸 게 있으면 묻는 창
  Task<> use_window(PlayerId p, uint32_t timing, uint32_t hint);
  bool can_use(const Action& a);
  bool can_bet(const Action& a);
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
  void msg_reset();
  void msg_coin(PlayerId p);
  void msg_subscribers(PlayerId p);
  void msg_marker(ZoneId z, uint8_t kind);
  void msg_zones();
  void msg_start();
  void msg_turn();
  void enter_phase(uint32_t p);
  void on_move(const MoveRecord& r);
  void on_shuffle(ZoneId z);
  void msg_reveal(CardIdx c, bool everyone = false);
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
  bool call_immune(int ref, EffectId e, CardIdx src, PlayerId p, bool burst = false);
  bool call_group_check(int ref, const std::vector<CardIdx>& g);
  std::string call_cost(int ref, EffectId e, PlayerId p, const std::string& base);
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
  // 「アタックしているシグニとして場に出す」로 나온 시그니(WDK-F03-15 FAQ 2). 어택한 시그니 대신 배틀·데미지
  std::vector<std::pair<CardIdx, ObjId>> extra_attackers_;
  bool end_turn_requested_ = false;
  std::unordered_set<ObjId> attacked_;  // 이 턴에 어택한 객체
  bool grew_this_turn_ = false, removed_this_turn_ = false;
  std::unordered_map<ObjId, int32_t> last_levels_;  // 룰 처리 2의 B 판정용
  std::vector<CardIdx> deck_moved_;  // 지금 효과로 메인 덱에 옮겨진 카드
  EffectId deck_moved_effect_ = kNoEffect;
  PlayerId deck_moved_player_ = kNoPlayer;
};

}  // namespace wx
