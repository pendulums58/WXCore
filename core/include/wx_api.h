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
 *   MSG_START      u8 first_player
 *   MSG_ZONES      u16 n, n × { u16 id, u8 owner, u8 kind, u8 absent, u8 name_len, char name[],
 *                               u8 n_adj, u16 adj[], u16 front }
 *   MSG_NEW_TURN   u8 player, u32 turn_count
 *   MSG_NEW_PHASE  u32 phase
 *   MSG_MOVE       u32 old_handle, u32 new_handle, u32 cid, u16 from_zone, u16 to_zone,
 *                  u8 pos(0 맨 위/1 맨 아래), u8 kind(0 이동/1 아래에 둠/2 붙임/3 뒷면),
 *                  u32 host_handle, u8 face_up
 *   MSG_SHUFFLE    u16 zone, u16 n, u32 handles[n] (아래→위)
 *   MSG_FLAGS      u32 handle, u32 flags
 *   MSG_REVEAL     u32 handle, u32 cid          (앞면이 됨·공개)
 *   MSG_ATTACK     u32 handle
 *   MSG_BATTLE     u32 attacker, u32 defender, i32 attacker_power, i32 defender_power
 *   MSG_DAMAGE     u8 player
 *   MSG_REFRESH    u8 player
 *   MSG_TRIGGER    u8 player, u32 handle(0 = 카드 아님)
 *   MSG_REQUEST    u8 type, u8 player, u32 hint, u32 min, u32 max, u16 n, n × 선택지, u8 cancelable
 *                  선택지: SELECT_CARDS면 u32 handle,
 *                  SELECT_ACTION이면 u8 kind + u32 handle + u16 zone + u32 effect, 그 외 u32 값
 *                  kind: 0 페이즈 종료, 1 시그니 내기, 2 리무브, 3 카드 사용, 4 【起】, 5 그로우(어시스트), 6 키 내기
 *                  cancelable이면 wx_cancel로 사용 절차를 처음으로 되돌릴 수 있다(확정 전)
 *   MSG_WAITING    u8 player                    (다른 플레이어가 고르는 중)
 *   MSG_RETRY      u8 player, u16 len, char reason[len]
 *   MSG_WIN        u8 winner
 *   MSG_COIN       u8 player, u8 coins          (가진 코인 수)
 *   MSG_MARKER     u16 zone, u8 kind(1 ゲート), u8 count
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

#define WX_SCHEMA_VERSION 1

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

/* 요청 종류(MSG_REQUEST type) */
#define WX_REQ_YES_NO 0
#define WX_REQ_SELECT_CARDS 1
#define WX_REQ_SELECT_OPTION 2
#define WX_REQ_SELECT_ACTION 3

/* 카드 데이터. 문자열 목록은 '\n'으로 잇는다. 포인터는 콜백이 끝날 때까지만 유효하면 된다. */
typedef struct wx_card_data {
  uint32_t cid;
  uint32_t alias;
  uint32_t type;
  uint8_t color;
  int32_t level;
  int32_t limit;
  int32_t power;
  const char* classes;
  const char* limit_cond;
  const char* cost_ena;
  const char* grow_ena;
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

int wx_create_duel(const wx_duel_options* opt, wx_duel** out);
void wx_destroy_duel(wx_duel* duel);

int wx_add_deck(wx_duel* duel, uint8_t player, const uint32_t* main, size_t n_main, const uint32_t* lrig,
                size_t n_lrig);
int wx_start(wx_duel* duel);
int wx_process(wx_duel* duel);

/* 쌓인 메시지 바이트 수를 돌려준다. buf가 있고 cap이 충분하면 복사하고 비운다. */
size_t wx_get_messages(wx_duel* duel, uint8_t view, uint8_t* buf, size_t cap);

int wx_set_response(wx_duel* duel, const uint32_t* picks, size_t n);
/* 확정 전 선택(cancelable)을 취소한다. 아무 상태도 바뀌지 않은 채 행동 선택으로 돌아간다 */
int wx_cancel(wx_duel* duel);

/* 메시지 하나(size 필드부터)를 사람이 읽는 한 줄로. 필요한 길이(끝의 0 제외)를 돌려준다. */
size_t wx_dump_message(const uint8_t* msg, size_t len, char* out, size_t cap);

/* 테스트 모드(WX_FLAG_TEST_MODE가 없으면 WX_ERR_TEST_MODE) */
int wx_test_add_card(wx_duel* duel, uint32_t cid, uint8_t owner, uint16_t zone, uint32_t* handle);
int wx_test_begin(wx_duel* duel, uint8_t turn_player, uint32_t phase, int first_turn);
/* 카드를 그 존으로 바로 옮긴다(이벤트 없음). 라이프·에나 개수도 이것과 wx_test_add_card로 맞춘다.
 * bottom이면 맨 아래. 옮긴 뒤 handle이 바뀔 수 있다 */
int wx_test_move_card(wx_duel* duel, uint32_t handle, uint16_t zone, int bottom, uint32_t* new_handle);
/* 파워를 그 값으로 만드는 효과를 건다(해제 없음). 값을 직접 바꾸지 않고 효과로 등록한다 */
int wx_test_set_power(wx_duel* duel, uint32_t handle, int32_t power);
/* 마지막 응답(확정·취소)을 되돌린다. 그 요청을 다시 기다리는 상태가 되고, 모든 뷰에 MSG_RESET부터
 * 다시 보낸다. 아직 꺼내지 않은 메시지는 버려진다. 되돌릴 응답이 없으면 WX_ERR_STATE */
int wx_test_undo(wx_duel* duel);

#ifdef __cplusplus
}
#endif

#endif
