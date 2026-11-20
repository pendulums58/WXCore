#pragma once
#include <cstdint>

namespace wx {

using PlayerId = uint8_t;  // 0 = P1, 1 = P2
constexpr PlayerId kNoPlayer = 0xFF;
inline PlayerId opponent(PlayerId p) { return static_cast<PlayerId>(p ^ 1); }

using ZoneId = uint16_t;
constexpr ZoneId kNoZone = 0xFFFF;

// 물리 카드 번호. 대전 내내 고정이고 코어 내부에서만 쓴다.
using CardIdx = uint32_t;
constexpr CardIdx kNoCard = 0xFFFFFFFF;

// 객체 번호. 장을 떠나거나 뒷면이 되면 새로 발급한다(설계: 객체 동일성).
// 효과의 고정 대상·대상 지정은 이 번호를 잡고, 번호가 바뀌면 끊긴다.
using ObjId = uint32_t;
constexpr ObjId kNoObj = 0;

using Cid = uint32_t;

}  // namespace wx
