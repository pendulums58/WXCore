#pragma once
#include <deque>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>

#include "common.h"

namespace wx {

using EffectId = uint32_t;
constexpr EffectId kNoEffect = 0;

// 효과 타입(유프로식). SINGLE/FIELD만 있고 발동 플래그가 없으면 지속 효과다.
enum EffectType : uint32_t {
  EFFECT_TYPE_SINGLE = 0x1,
  EFFECT_TYPE_FIELD = 0x2,
  EFFECT_TYPE_ACTIVATE = 0x10,   // 아츠·스펠·피스
  EFFECT_TYPE_IGNITION = 0x40,   // 【起】
  EFFECT_TYPE_TRIGGER_O = 0x80,  // 【自】 임의
  EFFECT_TYPE_TRIGGER_F = 0x200, // 【自】 강제
  EFFECT_TYPE_LIFEBURST = 0x400,
  EFFECT_TYPE_TRAP = 0x800,       // 【トラップアイコン】
};
constexpr uint32_t kActionTypes = EFFECT_TYPE_ACTIVATE | EFFECT_TYPE_IGNITION | EFFECT_TYPE_TRIGGER_O |
                                  EFFECT_TYPE_TRIGGER_F | EFFECT_TYPE_LIFEBURST | EFFECT_TYPE_TRAP;

// 효과 코드. 지속 효과는 코드가 정하는 레이어에서 적용된다(설계: 레이어).
enum EffectCode : uint32_t {
  // 레이어 1: 정체·복사
  EFFECT_COPY = 1,  // value = cid. 그 카드와 같은 카드가 된다
  // 레이어 2: 특성
  EFFECT_CHANGE_COLOR = 100,
  EFFECT_ADD_COLOR = 101,
  EFFECT_ADD_CLASS = 102,  // value = 클래스 코드(aux.Class(sys, race))
  EFFECT_CHANGE_LEVEL = 103,
  EFFECT_UPDATE_LEVEL = 104,
  EFFECT_UPDATE_LIMIT = 105,
  // 레이어 3: 능력 획득·상실
  EFFECT_LOSE_ABILITY = 200,
  // 레이어 4·5: 파워
  EFFECT_SET_POWER = 300,
  EFFECT_UPDATE_POWER = 301,
  EFFECT_SET_BASE_POWER = 302,  // 「基本パワーは…になる」: 인쇄 파워를 바꾼다. SET_POWER·UPDATE_POWER보다 먼저
  // 억제(何もしない). 코어 내부용 — 스크립트는 Duel 함수로 만든다
  EFFECT_SUPPRESS = 400,

  EFFECT_MULTI_ENA = 500,  // 【マルチエナ】: 에나 지불 때 모든 색(range = LOCATION_ENA)

  // 키워드 능력(용어집). 인쇄하거나 「得る」로 부여한다
  EFFECT_LANCER = 600,        // 【ランサー】: 배틀로 시그니를 바니시하면 라이프 클로스 1장 크러시(트리거)
  EFFECT_TRIPLE_CRUSH = 606,  // 【トリプルクラッシュ】: 어택 데미지로 3장 크러시
  EFFECT_DOUBLE_CRUSH = 601,  // 【ダブルクラッシュ】: 어택 데미지로 2장 크러시
  EFFECT_ASSASSIN = 602,      // 【アサシン】: 정면 시그니가 없는 것처럼 데미지
  EFFECT_S_LANCER = 603,      // 【Ｓランサー】: 【ランサー】와 같고, 라이프 클로스가 없으면 대신 데미지. 둘 다 있으면 이쪽 1번(용어집: Sランサー)

  // 「…は以下の能力を得る」(FIELD, 동적). SetLabelObject의 효과를 대상마다 복제해 부여한다
  EFFECT_GRANT = 700,

  EFFECT_CANNOT_ATTACK = 800,       // 「アタックできない」
  EFFECT_UPDATE_HAND_LIMIT = 801,   // 손패 상한 ±(FIELD, SetTargetRange(1,0)=자기, (0,1)=상대. WDK09-009 FAQ 1)
  EFFECT_CANNOT_GUARD = 802,
  EFFECT_CANNOT_BANISH = 803,       // 「バニッシュされない」: 효과·배틀·룰 처리(파워 0 이하) 모두(룰 해설 160513_02 問1, WDK08-Y07 FAQ 3)
  EFFECT_PREVENT_DAMAGE = 804,      // 「次にダメージを受ける場合、代わりにダメージを受けない」(플레이어 효과, 한 번 쓰면 사라진다. WDK08-L06)
  EFFECT_CANNOT_CRUSH = 805,        // 「ライフクロスはクラッシュされない」(플레이어 효과). 어택·효과 모두(WD06-008 FAQ 1)
  EFFECT_MUST_ATTACK = 806,         // 「可能ならばアタックしなければならない」: 시그니 어택 스텝에 어택할 수 있으면 끝낼 수 없다(WD07-004 FAQ 1)
  EFFECT_MUST_FRONT = 807,          // 「対戦相手がシグニを配置する場合、可能ならばこのシグニの正面に」(시그니 자신의 키워드형). 여럿이면 놓는 쪽이 고른다(WD07-009 FAQ 1)
  EFFECT_FREE_IGNITION = 808,       // 「次にそれの【起】能力を使用する場合、その能力の使用コストは《黒×0》になる」: 다음 【起】 한 번 코스트 없음(WD08-001)
  // 레조나의 출현 조건(용어집: 出現条件. 코스트도 효과도 아니다). SINGLE, range = LOCATION_LDECK.
  // value = 트래시에 둘 장수(label > 0이면 label~value장), check_ref = 고른 조합 (g) → bool, target_self = 그 카드를 고르는 위치, target_ref = (e,c) 필터, timing = TIMING_*
  EFFECT_RESONA = 809,
  // 크로스 조건(용어집: クロス条件). SINGLE. value = 짝의 cid(동명이 갈리면 대표 cid), label = CROSS_*. 여러 개면 「か」
  EFFECT_CROSS = 810,
  // 「…の効果を受けない」(용어집: 効果を受けない). value = (e, 출처 카드, 출처 플레이어) → bool. 파워·텍스트·색 등의 변경, 이동, 상태 변경을 막는다
  EFFECT_IMMUNE = 811,
  EFFECT_BANISH_TO_TRASH = 812,  // 「バニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる」. 놓이는 곳만 바꾼다(WXK11-032 FAQ)
  EFFECT_SKIP_GROW = 834,
  EFFECT_SIGNI_LIMIT = 837,
  EFFECT_LTRASH_IGNITION = 843,  // 「このルリグはあなたのルリグトラッシュにあるルリグの【起】能力を持つ」(SINGLE)
  EFFECT_IGNORE_LIMIT = 844,     // 「あなたが使用するアーツとスペルの限定条件は無視される」(플레이어에)
  EFFECT_NO_HAND_ADD = 845,      // 「自分のターンの間、グロウフェイズとドローフェイズ以外でカードを引いたり手札に加えることができない」(플레이어에)
  EFFECT_NO_OPP_POWER = 846,     // 「対戦相手の効果によって、シグニのパワーは増減しない」(FIELD. 가진 쪽의 상대가 만든 증감을 무시)
  EFFECT_NO_SELF_TRASH = 849,   // 「あなたは、自分でこのシグニを場からトラッシュに置くことができない」(SINGLE. 리무브·코스트·효과·출현 조건. 룰 처리는 된다)
  EFFECT_REVEAL_PLUS = 848,
  EFFECT_CANNOT_GROW = 858,     // 「あなたはグロウできない」(플레이어에. 효과로 그로우하는 것도. WX10-011 FAQ 1)
  EFFECT_RESONA_TO_LTRASH = 857,  // 「このシグニがバニッシュされる場合、ルリグデッキに戻る代わりにルリグトラッシュに置かれる」(SINGLE)
  EFFECT_INVERT_PLUS = 853,     // 「対戦相手のシグニのパワーが対戦相手の効果によって＋される場合、代わりに－される」(FIELD, 플레이어에)
  EFFECT_KILL_TO_TRASH = 854,   // 「対戦相手のシグニがこのシグニによってバニッシュされる場合、…代わりにトラッシュ」(SINGLE, 배틀·이 카드의 효과)
  EFFECT_SKIP_SIGNI_ATTACK = 855,  // 「このターン、…シグニアタックステップをスキップする」(플레이어에)
  EFFECT_SKIP_LRIG_ATTACK = 856,   // 「このターン、…ルリグアタックステップをスキップする」(플레이어에)
  EFFECT_NO_DAMAGE = 850,       // 「このターン、あなたはダメージを受けない」(플레이어에. 쓰여도 사라지지 않는다)
  EFFECT_ZONE_LOCK = 851,       // 「…それがあったシグニゾーンにシグニを新たに配置することができない」(플레이어에, value = 존 번호)
  EFFECT_ADD_PAY_COLOR = 852,   // 「《白》を支払う際、代わりにエナゾーンからこのシグニをトラッシュに置いてもよい」(SINGLE, value = 색 비트)     // 「このターン、…デッキの上から特定の値の枚数のカードを公開する場合、代わりに１枚多く公開してもよい」(플레이어에. aux.RevealCount)
  EFFECT_NEGATE_NEXT_ATTACK = 847,  // 「次にセンタールリグかシグニがアタックしたとき、そのアタックを無効にする」(플레이어에, 한 번)      // 「シグニを１体しか場に出すことができない」(FIELD를 플레이어에, value = 체수)
  EFFECT_DRAW_PHASE_COUNT = 838,  // 「ドローフェイズにカードを１枚しか引くことができない」(FIELD를 플레이어에, value = 장수)
  EFFECT_ZERO_TO_TRASH = 839,    // 「パワーが０以下のシグニがバニッシュされる場合、…代わりにトラッシュに」(FIELD를 플레이어에)
  EFFECT_DOUBLE_MINUS = 840,     // 「あなたのシグニの効果で対戦相手のシグニのパワーが－される場合、代わりに２倍」(플레이어에. aux.AddPower가 본다)
  EFFECT_NO_REMOVE = 841,        // 「カードの効果を除き、自分で自分のシグニを場からトラッシュに置くことができない」(플레이어에)
  EFFECT_NO_NEGATE = 842,        // 「次にスペルを使用する場合…対戦相手の効果によって打ち消されない」(플레이어에, EFFECT_FLAG_NEXT_USE)
  // 「…ルリグのグロウコストは《無×0》になる」(FIELD를 플레이어에, target_ref = (e,c) 루리그 덱의 그 루리그)
  EFFECT_GROW_COST_ZERO = 835,
  // 「このシグニのパワーがN以上になったとき」를 보게 한다(SINGLE, value = N). 넘으면 EVENT_POWER_REACHED
  EFFECT_POWER_WATCH = 836,        // 「グロウフェイズをスキップする」(FIELD, SetTargetRange(1,0)=자기)
  EFFECT_SKIP_ENA = 813,         // 「エナフェイズをスキップする」(FIELD, SetTargetRange(1,0)=자기, (0,1)=상대)
  EFFECT_ATTACK_ONCE = 814,      // 「このターン、…はそれぞれ一度しかアタックできない」
  EFFECT_GUARD_ICON = 815,       // 《ガードアイコン》を持つ(패)
  // 그로우 절차. SINGLE. cost_ref = 【グロウ】 조건(chk==0: 채울 수 있는가, 아니면 실행), declare_ref·min_cost_ref = 「グロウするためのコストは…減る」
  EFFECT_GROW_PROC = 816,
  EFFECT_NO_GUARD = 817,          // 「【ガード】ができない」(FIELD, SetTargetRange(0,1)=상대)
  EFFECT_GRANT_LIFEBURST = 818,   // 「あなたのすべての領域にある【ライフバースト】を持たないカードは【ライフバースト】…を得る」(FIELD, SetLabelObject = 라이프 버스트 원형. value 1이면 이미 가진 카드도 하나 더)
  // 「使用コストは…減る」(카드 밖에서). FIELD, SetTargetRange(1,0), target_ref = (e,c) 어느 카드, ena_cost = 빼는 기호, value = 몇 번
  EFFECT_REDUCE_COST = 821,
  // ライズ条件(용어집: ライズ. 코스트도 효과도 아니다). SINGLE. target_ref = (e,c) 밑이 될 자기 시그니. 그 시그니가 있는 존에 낸다
  EFFECT_RISE = 823,
  EFFECT_ACCE = 824,              // 《アクセアイコン》를 가졌다(SINGLE 표시)
  // 「正面にアタックする場合、正面に加えてその隣のシグニゾーン１つにアタックしてもよい」(SINGLE)
  EFFECT_ATTACK_NEIGHBOR = 825,
  // 「あなたの能力か効果１つによって…レベルを参照する場合、１～４いずれかのレベル１つとして扱ってもよい」(FIELD, 덱·패·트래시의 카드에)
  EFFECT_ANY_LEVEL = 826,
  // 「バニッシュされる場合、代わりにそのシグニに付いている【チャーム】１枚をトラッシュに置いてもよい」(FIELD·SINGLE)
  EFFECT_CHARM_GUARD = 827,
  EFFECT_LEAVE_EXCLUDE = 828,     // 장을 떠나는 경우 대신 게임에서 제외(SINGLE)
  // 「あなたのライフバーストが発動する場合、代わりに…二度発動する」(FIELD를 플레이어에)
  EFFECT_DOUBLE_BURST = 829,
  // 「あなたの他の…シグニ１体が対戦相手の効果によって場を離れる場合、代わりに…このシグニのパワーを－Nしてもよい」(FIELD, value = 파워)
  EFFECT_LEAVE_GUARD = 830,
  // 「手札から《ガードアイコン》を持つカードを追加でN枚捨てないかぎり【ガード】ができない」(FIELD를 플레이어에, value = N. 겹친다)
  EFFECT_GUARD_EXTRA = 831,
  // 「…の効果によってバニッシュされない」. value_ref = (e,sc,sp): 그 효과의 카드·플레이어(EFFECT_IMMUNE과 같다). 룰·배틀로는 바니시된다
  EFFECT_BANISH_IMMUNE = 832,
  EFFECT_CANNOT_USE = 833,        // 「…を使用できない」(FIELD를 플레이어에, target_ref = (e,c) 어느 카드. 아츠·스펠)
  EFFECT_CANNOT_PLAY = 822,       // 「新たに場に出すことができない」(SINGLE, 놓으려는 시그니 자신)
  EFFECT_CANNOT_USE_ARTS = 820,   // 「アーツを使用できない」(FIELD, SetTargetRange(1,0)=자기)
  EFFECT_DISABLE_ABILITY = 819,   // 그 분류의 능력을 쓸 수 없다·발동하지 않는다. value = ABILITY_* 비트(「【出】能力は発動しない」)
};

// EFFECT_CROSS의 label: 이 시그니가 짝의 왼쪽/오른쪽에 있으면 크로스 상태
constexpr int64_t CROSS_LEFT = 0;   // 「《X》の左」
constexpr int64_t CROSS_RIGHT = 1;  // 「《X》の右」
// EFFECT_CANNOT_CRUSH의 value: 「ダメージ以外によってはクラッシュされない」(WD13-010)
constexpr int32_t CRUSH_NON_DAMAGE = 1;

// SetProperty. EFFECT_REDUCE_COST: 「次に…を使用する場合」 한 번 쓰면 사라진다
constexpr uint32_t EFFECT_FLAG_NEXT_USE = 0x1;

// 능력의 분류(비트). 타입·코드에서 정하고(ability_type_of), 다르면 SetAbilityType으로 정한다.
// 능력이 아닌 것(생성된 지속 효과·크로스 조건 등)은 0
constexpr uint32_t ABILITY_AUTO = 0x1;        // 【自】
constexpr uint32_t ABILITY_ON_PLAY = 0x2;     // 【出】
constexpr uint32_t ABILITY_IGNITION = 0x4;    // 【起】
constexpr uint32_t ABILITY_CONTINUOUS = 0x8;  // 【常】
constexpr uint32_t ABILITY_LIFEBURST = 0x10;  // 【ライフバースト】
constexpr uint32_t ABILITY_TRAP = 0x40;       // 【トラップアイコン】
constexpr uint32_t ABILITY_USE = 0x20;        // 아츠·스펠·피스의 사용 효과

// 리셋. RESET_PHASE + PHASE_*: 그 페이즈 끝에 사라진다.
// 장을 떠나거나 뒷면이 되면 생성 효과는 객체와 함께 자동으로 끊기므로
// RESET_EVENT/RESETS_STANDARD는 유프로 스크립트 호환용으로만 받는다.
// RESET_PHASE | PHASE_END처럼 섞어 쓰므로 enum이 아니라 정수 상수로 둔다.
constexpr uint32_t RESET_PHASE = 0x40000000;
// 「次のあなたのターンまで」: 만든 플레이어의 다음 턴이 시작하기 직전에 사라진다(WDK10-009 FAQ)
constexpr uint32_t RESET_MY_TURN = 0x20000000;
constexpr uint32_t RESET_EVENT = 0x00001000;
constexpr uint32_t RESETS_STANDARD = 0x01fe0000;

constexpr uint32_t PHASE_UP = 0x01;
constexpr uint32_t PHASE_DRAW = 0x02;
constexpr uint32_t PHASE_ENA = 0x04;
constexpr uint32_t PHASE_GROW = 0x08;
constexpr uint32_t PHASE_MAIN = 0x10;
constexpr uint32_t PHASE_ATTACK = 0x20;
constexpr uint32_t PHASE_END = 0x40;

struct Effect {
  EffectId id = kNoEffect;
  uint32_t type = 0;
  uint32_t code = 0;
  uint32_t property = 0;
  uint32_t ability_type = 0;  // SetAbilityType으로 정한 분류. 0이면 ability_type_of가 정한다

  CardIdx owner_card = kNoCard;  // 만든 카드(e:GetOwner)
  CardIdx handler = kNoCard;     // 등록된 카드. kNoCard면 플레이어에 등록
  PlayerId owner_player = kNoPlayer;

  // 출처 분류. initial_effect 안에서 등록되면 인쇄(복사로 돌아도 인쇄).
  bool printed = false;
  bool granted = false;          // 능력 부여로 등록된 능력
  Cid text_cid = 0;              // 인쇄: 어느 텍스트의 능력인가
  EffectId copy_of = kNoEffect;  // 복사로 생긴 인쇄 효과면 그 복사 효과
  ObjId bind_oid = kNoObj;       // 생성: 등록 당시 객체. 객체가 바뀌면 끊긴다
  uint64_t timestamp = 0;        // 생성 효과의 등록 시각

  uint32_t range = 0;  // 핸들러가 있어야 하는 LOCATION. 0 = 어디서나
  uint32_t target_self = 0, target_opp = 0;  // FIELD 대상 범위

  int32_t value = 0;
  int value_ref = 0;      // Lua 함수(e,c) → 값
  int target_ref = 0;     // 지속 FIELD: (e,c) → bool 대상 필터. 트리거: (e,tp,eg,ep,ev,re,r,rp,chk)
  int condition_ref = 0;  // Lua 함수(e) → bool. 트리거는 (e,tp,eg,ep,ev,re,r,rp)
  int operation_ref = 0;  // Lua 함수(e,tp,eg,ep,ev,re,r,rp)
  int cost_ref = 0;       // 에나 외 코스트. 확정 뒤, 대상보다 먼저 돈다
  int declare_ref = 0;    // 사용 선언 때(코스트 전, 취소 가능) 모드 선택. (e,tp,eg,ep,ev,re,r,rp). 트리거는 대상 바로 앞에
  int check_ref = 0;      // EFFECT_RESONA: 고른 출현 조건 조합 (g) → bool
  int min_cost_ref = 0;   // 아츠·스펠의 「使用コストは…減る」: (e,tp) → 가장 많이 줄였을 때의 에나 코스트(쓸 수 있는지 볼 때만)
  std::string ena_cost;   // 【起】의 에나 코스트. 아츠·스펠은 카드 데이터의 비용
  uint32_t timing = 0;    // 【起】의 사용 타이밍(TIMING_*). 0이면 메인 페이즈

  uint32_t reset = 0;
  uint32_t reset_count = 1;

  int64_t label = 0;
  uint32_t desc = 0;  // 효과 설명 번호(aux.Ability·aux.Stringid). 0 = 없음(설계: 효과 설명 문자열)

  // 《ターン1回》·《ゲーム1回》(용어집: ターン１回, ゲーム１回). 0 = 제한 없음
  uint32_t count_limit = 0;
  bool count_game = false;
  uint32_t count_used = 0;
  ObjId count_oid = kNoObj;  // 센 객체. 장을 떠났다 오면 새 객체라 다시 센다(턴 제한만)

  uint32_t coin_cost = 0;    // 코인 코스트(プライマル 등)
  uint32_t exceed = 0;       // エクシードＮ
  uint32_t encore = 0;       // アンコール 코인 수(아츠)
  std::string encore_cost;   // アンコール의 에나 코스트(アンコール －《黒》)
  uint32_t bet = 0;          // ベット 코인 수(아츠. 용어집: ベット)
  bool has_bet_cost = false;  // ベット하면 사용 코스트가 bet_cost로 바뀐다(WDK08-Y06 「ベットする場合、使用コストは…になる」)
  std::string bet_cost;

  EffectId label_effect = kNoEffect;  // SetLabelObject(EFFECT_GRANT의 원형)
  EffectId grant_parent = kNoEffect;  // EFFECT_GRANT가 만든 복제면 그 부여 효과
  EffectId grant_src = kNoEffect;     // EFFECT_LTRASH_IGNITION의 복제면 원래 【起】

  // EFFECT_SUPPRESS: 억제하는 (효과, 객체). 객체 kNoObj = 객체 무관(생성 효과)
  std::vector<std::pair<EffectId, ObjId>> snapshot;

  bool registered = false;
  bool deleted = false;

  bool is_continuous() const { return (type & kActionTypes) == 0; }
  bool is_ability() const { return printed || granted; }
  bool is_trigger() const { return (type & (EFFECT_TYPE_TRIGGER_F | EFFECT_TYPE_TRIGGER_O)) != 0; }
};

class EffectTable {
 public:
  EffectId create();
  Effect* get(EffectId id) { return valid(id) ? &list_[id - 1] : nullptr; }
  const Effect* get(EffectId id) const { return valid(id) ? &list_[id - 1] : nullptr; }
  size_t size() const { return list_.size(); }
  // 이 코드의 효과가 등록된 적이 있는가(없으면 찾아볼 필요가 없다)
  bool seen(uint32_t code) const { return seen_.count(code) != 0; }
  void mark(uint32_t code) { seen_.insert(code); }

  template <class F>
  void for_each(F&& f) {
    for (auto& e : list_)
      if (e.registered && !e.deleted) f(e);
  }

 private:
  bool valid(EffectId id) const { return id != kNoEffect && id <= list_.size(); }
  std::unordered_set<uint32_t> seen_;
  std::deque<Effect> list_;  // 추가해도 참조가 안 깨진다
};

}  // namespace wx
