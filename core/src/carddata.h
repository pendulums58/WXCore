#pragma once
#include <string>
#include <vector>

#include "common.h"

namespace wx {

// 카드 종류 비트. DB cards.kind(JSON 목록)를 비트로 바꾼 것.
enum CardType : uint32_t {
  TYPE_LRIG = 1u << 0,
  TYPE_SIGNI = 1u << 1,
  TYPE_ARTS = 1u << 2,
  TYPE_SPELL = 1u << 3,
  TYPE_ASSIST_LRIG = 1u << 4,
  TYPE_TOKEN = 1u << 5,
  TYPE_PIECE = 1u << 6,
  TYPE_KEY = 1u << 7,
  TYPE_RESONA = 1u << 8,
  TYPE_CRAFT = 1u << 9,
  TYPE_COIN = 1u << 10,
  TYPE_RELAY = 1u << 11,
};

// 색 비트. 백1 적2 청4 녹8 흑16, 0 = 무색(설계: 데이터)
enum CardColor : uint8_t {
  COLOR_WHITE = 1,
  COLOR_RED = 2,
  COLOR_BLUE = 4,
  COLOR_GREEN = 8,
  COLOR_BLACK = 16,
};

// 사용 타이밍(용어집: 使用タイミング)
constexpr uint32_t TIMING_MAIN = 1u << 0;
constexpr uint32_t TIMING_ATTACK = 1u << 1;
constexpr uint32_t TIMING_CUTIN = 1u << 2;  // 【スペルカットイン】

constexpr int32_t kPowerInfinity = 1 << 30;  // DB의 -1(∞)

// 프레임/서버가 콜백으로 넘겨주는 카드 데이터. 코어는 DB를 직접 열지 않는다.
struct CardData {
  Cid cid = 0;
  Cid alias = 0;  // 동명 취급 대표 cid. 0 = 자기가 대표
  uint32_t type = 0;
  uint8_t color = 0;
  int32_t level = 0;
  int32_t limit = 0;
  int32_t limit_cost = 0;  // 사용 리미트(WX22-025 FAQ 「リミット消費」). 0 = 레벨
  int32_t power = 0;
  std::vector<uint32_t> classes;     // 시그니 클래스 코드(class_code). 콜론 없는 클래스(精元 등)는 種族 0
  std::vector<uint32_t> lrig_types;  // 루리그 타입 ID
  std::vector<uint32_t> limit_cond;  // 한정 조건(루리그 타입 ID)
  std::vector<std::string> teams;       // チーム(용어집: チーム)
  int32_t coin = 0;        // 코인 아이콘: 센터 루리그로 오픈하거나 장에 나오면 그만큼 얻는다(PR-322 FAQ)
  uint32_t cost_coin = 0;  // 코인 코스트(키 등)
  std::string cost_ena;  // '{R}{C}{C}'. 루리그·어시스트 루리그는 그로우 코스트, 나머지는 사용 코스트
  bool guard = false;    // 가드 아이콘
  uint32_t timing = 0;   // 아츠·피스의 사용 타이밍(TIMING_*)
  bool life_burst = false;
};

// 시그니 클래스 하나 = (系統 ID, 種族 ID). ID는 카드 DB의 classes 표(공식 1~999, 오리카 1000~32767)
constexpr uint32_t class_code(uint32_t sys, uint32_t race) { return sys << 16 | race; }
constexpr uint32_t class_sys(uint32_t code) { return code >> 16; }
constexpr uint32_t class_race(uint32_t code) { return code & 0xFFFF; }

// 클래스 일치 판정. sys·race 중 0은 「아무거나」(둘 다 0으로는 부르지 않는다).
// 용어집 クラス: 좌우가 완전히 같아야 같은 클래스, 오른쪽(種族)만 쓰면 系統과 상관없이 해당.
// WX20-007: 왼쪽(系統)만 쓰면 그 系統 전부. 콜론 없는 클래스(精元·解放派 등)도 系統 자리라 이 경우로 판정한다
constexpr bool class_matches(uint32_t code, uint32_t sys, uint32_t race) {
  return (!sys || class_sys(code) == sys) && (!race || class_race(code) == race);
}

}  // namespace wx
