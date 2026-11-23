/* WIXOSS 시뮬레이터 코어 공개 C API. 외부에 노출하는 것은 이 헤더뿐이다.
 *
 * 루프
 *   wx_create_duel → wx_add_deck ×2 → wx_start →
 *   반복 { wx_process; wx_get_messages(뷰마다); NEED_RESPONSE면 wx_set_response }
 *
 * 메시지 형식(리틀엔디언 바이너리)
 *   메시지 하나 = u32 size(뒤따르는 바이트 수) + u16 type + 본문
 *   카드는 handle(객체 번호)로 가리킨다. 장을 떠나거나 셔플되면 handle이 바뀐다.
 *   비공개 카드는 그 뷰에 cid 0으로 온다.
 *
 *   MSG_START      u8 first_player (선공을 정한 그 자리, 引き直し 전)
 *   MSG_ZONES      u16 n, n × { u16 id, u8 owner, u8 kind, u8 absent, u8 name_len, char name[],
 *                               u8 n_adj, u16 adj[], u16 front }
 *   MSG_NEW_TURN   u8 player, u32 turn_count
 *   MSG_NEW_PHASE  u32 phase
 *   MSG_MOVE       u32 old_handle, u32 new_handle, u32 cid, u16 from_zone, u16 to_zone,
 *                  u8 pos(0 맨 위/1 맨 아래), u8 kind(0 이동/1 아래에 둠/2 붙임/3 뒷면),
 *                  u32 host_handle, u8 face_up, u16 print(판본, 모르면 0)
 *   MSG_SHUFFLE    u16 zone, u16 n, u32 handles[n] (아래→위)
 *   MSG_FLAGS      u32 handle, u32 flags
 *   MSG_REVEAL     u32 handle, u32 cid, u16 print (앞면이 됨·공개)
 *   MSG_ATTACK     u32 handle
 *   MSG_BATTLE     u32 attacker, u32 defender, i32 attacker_power, i32 defender_power
 *   MSG_DAMAGE     u8 player
 *   MSG_REFRESH    u8 player
 *   MSG_TRIGGER    u8 player, u32 handle(0 = 카드 아님), u32 desc
 *   MSG_REQUEST    u8 type, u8 player, u32 hint, u32 min, u32 max, u16 n, n × 선택지, u8 cancelable,
 *                  u32 source(무엇에 대한 요청인가: 카드 handle, 0 = 없음), u32 source_desc
 *                  선택지: SELECT_CARDS면 u32 handle,
 *                  SELECT_ACTION이면 u8 kind + u32 handle + u16 zone + u32 effect + u32 desc,
 *                  그 외 u32 값 + u32 handle(그 선택지의 카드, 0 = 없음) + u32 desc
 *                  desc: 효과 설명 번호 = cid × 32 + slot(0~15 str, 16~30 능력 줄 0~14, 31 라이프 버스트). 0 = 없음
 *                  kind: 0 페이즈 종료, 1 시그니 내기, 2 리무브, 3 카드 사용, 4 【起】, 5 그로우(어시스트), 6 키 내기
 *                  cancelable이면 wx_cancel로 사용 절차를 처음으로 되돌릴 수 있다(확정 전)
 *   MSG_WAITING    u8 player                    (다른 플레이어가 고르는 중)
 *   MSG_RETRY      u8 player, u16 len, char reason[len]
 *   MSG_WIN        u8 winner
 *   MSG_COIN       u8 player, u8 coins          (가진 코인 수)
 *   MSG_MARKER     u16 zone, u8 kind(1 ゲート, 2 ウィルス), u8 count
 *   MSG_RESET      (본문 없음) 지금까지 받은 메시지를 모두 버린다. 이어서 처음부터 다시 온다(테스트 모드 되돌리기)
 *
 * 응답(wx_set_response)
 *   SELECT_CARDS: 고른 handle들 / SELECT_ACTION·SELECT_OPTION: 선택지 번호 / YES_NO: 0 또는 1
 */
#ifndef WX_API_H
#define WX_API_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define WX_SCHEMA_VERSION 5  /* 2: 요청에 source·선택지 카드·desc, 3: MSG_TRIGGER에 desc, 4: MOVE·REVEAL에 print, 5: MARKER 2 ウィルス */

/* 코어 API 버전. 프레임은 major가 같은 코어 DLL만 쓴다(저장소로 받은 코어가 안 맞으면 동봉 코어).
 * 함수·구조체를 바꾸거나 빼면 major, 덧붙이기만 하면 minor를 올린다 */
#define WX_API_VERSION_MAJOR 2  /* 2: wx_card_data의 클래스·루리그 타입·한정 조건이 ID 배열 */
#define WX_API_VERSION_MINOR 3  /* 2.1: wx_add_deck_prints, wx_card_info.print, 2.2: WX_KW_S_LANCER, 2.3: wx_query_granted */

/* 코어를 DLL로 빌드할 때 내보낸다(정적 링크·프레임의 불러오기 쪽에서는 비어 있다) */
#if defined(_WIN32) && defined(WX_BUILD_DLL)
#define WX_API __declspec(dllexport)
#elif defined(WX_BUILD_DLL)
#define WX_API __attribute__((visibility("default")))
#else
#define WX_API
#endif

/* (major << 16) | minor */
WX_API uint32_t wx_api_version(void);
/* 이 코어가 쓰는 메시지·응답 스키마(WX_SCHEMA_VERSION) */
WX_API uint32_t wx_schema_version(void);

/* 결과 */
#define WX_OK 0
#define WX_ERR_VERSION 1
#define WX_ERR_ARGS 2
#define WX_ERR_STATE 3
#define WX_ERR_INVALID 4  /* 응답 거부(MSG_RETRY가 나간다) */
#define WX_ERR_TEST_MODE 5

/* wx_process */
#define WX_CONTINUE 0
#define WX_NEED_RESPONSE 1
#define WX_END 2

/* 뷰 */
#define WX_VIEW_P1 0
#define WX_VIEW_P2 1
#define WX_VIEW_SPECTATOR 2  /* 공개 정보만 */
#define WX_VIEW_ALL 3        /* 전부(리플레이, 전체 공개 관전) */

/* 대전 플래그 */
#define WX_FLAG_TEST_MODE 0x1
#define WX_FLAG_ALWAYS_ASK 0x2

/* 메시지 종류 */
#define WX_MSG_START 1
#define WX_MSG_ZONES 2
#define WX_MSG_NEW_TURN 3
#define WX_MSG_NEW_PHASE 4
#define WX_MSG_MOVE 5
#define WX_MSG_SHUFFLE 6
#define WX_MSG_FLAGS 7
#define WX_MSG_REVEAL 8
#define WX_MSG_ATTACK 9
#define WX_MSG_BATTLE 10
#define WX_MSG_DAMAGE 11
#define WX_MSG_REFRESH 12
#define WX_MSG_TRIGGER 13
#define WX_MSG_REQUEST 14
#define WX_MSG_WAITING 15
#define WX_MSG_RETRY 16
#define WX_MSG_WIN 17
#define WX_MSG_RESET 18
#define WX_MSG_COIN 19
#define WX_MSG_MARKER 20

/* 요청 힌트(MSG_REQUEST hint): 무엇을 고르는 요청인가 */
#define WX_HINT_NONE 0
#define WX_HINT_MULLIGAN 1
#define WX_HINT_START_LRIG 2
#define WX_HINT_CENTER_LRIG 3
#define WX_HINT_ENA_CHARGE 4
#define WX_HINT_GROW 5
#define WX_HINT_PAY_ENA 6
#define WX_HINT_MAIN 7
#define WX_HINT_REMOVE 8
#define WX_HINT_ATTACK_SIGNI 9
#define WX_HINT_ATTACK_LRIG 10
#define WX_HINT_GUARD 11
#define WX_HINT_DISCARD 12
#define WX_HINT_TRIGGER_ORDER 13
#define WX_HINT_USE_TRIGGER 14
#define WX_HINT_LIFEBURST 15
#define WX_HINT_RULE_TRASH 16
#define WX_HINT_SCRIPT 17
#define WX_HINT_PRE_ATTACK 18
#define WX_HINT_DEFENSE 19
#define WX_HINT_CUTIN 20
#define WX_HINT_TARGET 21
#define WX_HINT_MODE 22
#define WX_HINT_SELECT 23
#define WX_HINT_ZONE 24
#define WX_HINT_EXCEED 25
#define WX_HINT_ENCORE 26
#define WX_HINT_DECLARE 27
#define WX_HINT_ORDER 28
#define WX_HINT_BET 29

/* 페이즈(MSG_NEW_PHASE) */
#define WX_PHASE_UP 0x01
#define WX_PHASE_DRAW 0x02
#define WX_PHASE_ENA 0x04
#define WX_PHASE_GROW 0x08
#define WX_PHASE_MAIN 0x10
#define WX_PHASE_ATTACK 0x20
#define WX_PHASE_END 0x40

/* 행동 종류(SELECT_ACTION 선택지 kind) */
#define WX_ACT_END 0
#define WX_ACT_PLAY_SIGNI 1
#define WX_ACT_REMOVE 2
#define WX_ACT_USE 3
#define WX_ACT_ABILITY 4
#define WX_ACT_GROW 5
#define WX_ACT_KEY 6

/* 요청 종류(MSG_REQUEST type) */
#define WX_REQ_YES_NO 0
#define WX_REQ_SELECT_CARDS 1
#define WX_REQ_SELECT_OPTION 2
#define WX_REQ_SELECT_ACTION 3

/* 카드 데이터. 문자열 목록은 '\n'으로 잇는다. 포인터는 콜백이 끝날 때까지만 유효하면 된다.
   클래스는 코드(系統 ID << 16 | 種族 ID), 루리그 타입·한정 조건은 루리그 타입 ID. ID는 카드 DB의 classes 표 */
typedef struct wx_card_data {
  uint32_t cid;
  uint32_t alias;
  uint32_t type;
  uint8_t color;
  int32_t level;
  int32_t limit;
  int32_t limit_cost; /* 사용 리미트: 시그니를 낼 때 레벨 대신 리미트 합계에 더하는 값. 0 = 레벨 */
  int32_t power;
  const uint32_t* classes;
  size_t n_classes;
  const uint32_t* lrig_types;
  size_t n_lrig_types;
  const uint32_t* limit_cond;
  size_t n_limit_cond;
  const char* cost_ena; /* 루리그·어시스트 루리그는 그로우 코스트, 나머지는 사용 코스트 */
  uint8_t guard;
  uint8_t life_burst;
  uint32_t timing; /* 사용 타이밍 비트: 1 메인, 2 어택, 4 스펠 컷인 */
  const char* teams;
  int32_t coin;       /* 코인 아이콘 */
  uint32_t cost_coin; /* 코인 코스트 */
} wx_card_data;

/* 성공하면 1. 코어는 파일을 직접 열지 않고 이 콜백들로만 데이터를 받는다. */
typedef int (*wx_card_reader)(void* user, uint32_t cid, wx_card_data* out);
/* name 예: "c123.lua". 돌려준 버퍼는 콜백이 끝날 때까지만 유효하면 된다. 없으면 NULL */
typedef const char* (*wx_script_reader)(void* user, const char* name, size_t* len);
typedef void (*wx_log_handler)(void* user, const char* msg);

typedef struct wx_duel_options {
  uint32_t schema_version; /* WX_SCHEMA_VERSION */
  uint64_t seed;
  uint32_t flags;          /* WX_FLAG_* */
  uint8_t first_player;    /* 0, 1, 0xFF = 코어 PRNG로 */
  wx_card_reader card_reader;
  wx_script_reader script_reader;
  wx_log_handler log_handler;
  void* user;
} wx_duel_options;

typedef struct wx_duel wx_duel;

WX_API int wx_create_duel(const wx_duel_options* opt, wx_duel** out);
WX_API void wx_destroy_duel(wx_duel* duel);

WX_API int wx_add_deck(wx_duel* duel, uint8_t player, const uint32_t* main, size_t n_main, const uint32_t* lrig,
                size_t n_lrig);
/* wx_add_deck + 장마다 판본(카드 DB prints.idx, 1부터). prints가 NULL이면 모두 1. 판본은 화면용이고 룰과 무관하다 */
WX_API int wx_add_deck_prints(wx_duel* duel, uint8_t player, const uint32_t* main, const uint16_t* main_prints,
                              size_t n_main, const uint32_t* lrig, const uint16_t* lrig_prints, size_t n_lrig);
WX_API int wx_start(wx_duel* duel);
WX_API int wx_process(wx_duel* duel);

/* 쌓인 메시지 바이트 수를 돌려준다. buf가 있고 cap이 충분하면 복사하고 비운다. */
WX_API size_t wx_get_messages(wx_duel* duel, uint8_t view, uint8_t* buf, size_t cap);

WX_API int wx_set_response(wx_duel* duel, const uint32_t* picks, size_t n);
/* 확정 전 선택(cancelable)을 취소한다. 아무 상태도 바뀌지 않은 채 행동 선택으로 돌아간다 */
WX_API int wx_cancel(wx_duel* duel);

/* ── 상태 조회(읽기 전용) ──
 * 프레임은 메시지로 사건을 받고, 화면은 이 조회로 그린다(재접속·관전 중간 입장도 같은 길).
 * 모두 뷰를 받는다. 그 뷰가 모르는 카드는 cid와 값이 0이다. */

/* 키워드·속성 비트(wx_card_info.keywords) */
#define WX_KW_LANCER 0x1
#define WX_KW_DOUBLE_CRUSH 0x2
#define WX_KW_ASSASSIN 0x4
#define WX_KW_CANNOT_ATTACK 0x8
#define WX_KW_GUARD 0x10
#define WX_KW_LIFE_BURST 0x20
#define WX_KW_S_LANCER 0x40

typedef struct wx_card_info {
  uint32_t handle;
  uint32_t cid;        /* 지금 텍스트(복사 반영). 모르면 0 */
  uint8_t known;       /* 이 뷰가 카드를 아는가 */
  uint8_t owner, controller;
  uint8_t face_up;
  uint16_t zone;       /* 아래 카드·붙은 카드면 호스트의 존 */
  uint32_t host;       /* 아래·붙은 카드면 호스트 handle, 아니면 0 */
  uint32_t flags;      /* 1 다운, 2 동결 */
  uint32_t type;       /* 카드 종류 비트 */
  uint8_t color;
  int32_t level, limit, power; /* 효과를 반영한 현재 값 */
  uint32_t keywords;   /* WX_KW_* */
  uint16_t n_under, n_attached;
  uint16_t print;      /* 판본(덱에서 정한 것, 1부터). 모르면 0 */
} wx_card_info;

typedef struct wx_player_info {
  uint32_t coins;
  int32_t hand_limit;
  uint32_t refreshes_this_turn;
} wx_player_info;

typedef struct wx_game_info {
  uint8_t turn_player;
  uint32_t turn_count;
  uint32_t phase;      /* PHASE 비트(메시지 MSG_NEW_PHASE와 같다) */
  uint8_t ended;
  uint8_t winner;      /* 0xFF = 없음 */
} wx_game_info;

WX_API int wx_query_card(wx_duel* duel, uint8_t view, uint32_t handle, wx_card_info* out);
/* 존 안의 카드 handle(아래 → 위). 개수를 돌려준다. buf가 있으면 cap까지 채운다 */
WX_API size_t wx_query_zone(wx_duel* duel, uint8_t view, uint16_t zone, uint32_t* buf, size_t cap);
/* 장 위 카드의 아래 카드 handle(아래 → 위) */
WX_API size_t wx_query_under(wx_duel* duel, uint8_t view, uint32_t handle, uint32_t* buf, size_t cap);

/* 카드가 지금 가진 능력 중 부여된 것(「…を得る」). 인쇄 능력은 들어 있지 않다 */
typedef struct wx_granted_info {
  uint32_t desc;        /* 효과 설명 번호(문장). 0 = 없음 */
  uint32_t keyword;     /* 키워드 부여면 WX_KW_* 비트, 아니면 0 */
  uint32_t source_cid;  /* 부여한 카드(인쇄 cid). 모르면 0 */
} wx_granted_info;
/* 개수를 돌려준다. 이 뷰가 모르는 카드면 0 */
WX_API size_t wx_query_granted(wx_duel* duel, uint8_t view, uint32_t handle, wx_granted_info* buf, size_t cap);
WX_API int wx_query_player(wx_duel* duel, uint8_t player, wx_player_info* out);
WX_API int wx_query_game(wx_duel* duel, wx_game_info* out);
/* 존 정보(MSG_ZONES와 같다). 존 수를 돌려준다 */
WX_API size_t wx_zone_count(wx_duel* duel);
/* 그 존의 이름(널 종료), 주인, 【ゲート】 */
/* markers: 존 표식 비트(1 ゲート, 2 ウィルス) */
WX_API int wx_query_zone_info(wx_duel* duel, uint16_t zone, char* name, size_t cap, uint8_t* owner, uint8_t* markers);

/* 메시지 하나(size 필드부터)를 사람이 읽는 한 줄로. 필요한 길이(끝의 0 제외)를 돌려준다. */
WX_API size_t wx_dump_message(const uint8_t* msg, size_t len, char* out, size_t cap);

/* 테스트 모드(WX_FLAG_TEST_MODE가 없으면 WX_ERR_TEST_MODE) */
WX_API int wx_test_add_card(wx_duel* duel, uint32_t cid, uint8_t owner, uint16_t zone, uint32_t* handle);
WX_API int wx_test_begin(wx_duel* duel, uint8_t turn_player, uint32_t phase, int first_turn);
/* 카드를 그 존으로 바로 옮긴다(이벤트 없음). 라이프·에나 개수도 이것과 wx_test_add_card로 맞춘다.
 * bottom이면 맨 아래. 옮긴 뒤 handle이 바뀔 수 있다 */
WX_API int wx_test_move_card(wx_duel* duel, uint32_t handle, uint16_t zone, int bottom, uint32_t* new_handle);
/* 파워를 그 값으로 만드는 효과를 건다(해제 없음). 값을 직접 바꾸지 않고 효과로 등록한다 */
WX_API int wx_test_set_power(wx_duel* duel, uint32_t handle, int32_t power);
/* 마지막 응답(확정·취소)을 되돌린다. 그 요청을 다시 기다리는 상태가 되고, 모든 뷰에 MSG_RESET부터
 * 다시 보낸다. 아직 꺼내지 않은 메시지는 버려진다. 되돌릴 응답이 없으면 WX_ERR_STATE */
WX_API int wx_test_undo(wx_duel* duel);

#ifdef __cplusplus
}
#endif

#endif
