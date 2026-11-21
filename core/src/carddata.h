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
  int32_t power = 0;
  std::vector<std::string> classes;     // 시그니 클래스 / 루리그 타입
  std::vector<std::string> limit_cond;  // 한정 조건
  std::vector<std::string> teams;       // チーム(용어집: チーム)
  int32_t coin = 0;        // 코인 아이콘: 센터 루리그로 오픈하거나 장에 나오면 그만큼 얻는다(PR-322 FAQ)
  uint32_t cost_coin = 0;  // 코인 코스트(키 등)
  std::string cost_ena;  // '{R}{C}{C}'
  std::string grow_ena;  // 그로우 비용
  bool guard = false;    // 가드 아이콘
  uint32_t timing = 0;   // 아츠·피스의 사용 타이밍(TIMING_*)
  bool life_burst = false;
};

// 클래스 일치 판정(용어집: クラス).
// 「：」 좌우가 완전히 같으면 일치. 질의에 「：」가 없으면 오른쪽만 비교한다.
inline bool class_matches(const std::string& card_class, const std::string& query) {
  if (card_class == query) return true;
  static const std::string kSep = "\xEF\xBC\x9A";  // 「：」(U+FF1A)
  if (query.find(kSep) != std::string::npos) return false;
  auto pos = card_class.find(kSep);
  return pos != std::string::npos && card_class.compare(pos + kSep.size(), std::string::npos, query) == 0;
}

}  // namespace wx
