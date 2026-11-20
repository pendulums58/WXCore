#pragma once
// 에나 비용. 표기는 MTG식 {W}{R}{U}{G}{B}{C}, 혼성 {W/B}(설계: 데이터).
#include <cstdint>
#include <string>
#include <vector>

namespace wx {

// 기호 하나 = 낼 수 있는 색 비트. 0 = 무색(어느 에나든 된다)
std::vector<uint8_t> parse_ena_cost(const std::string& cost);

// 고른 에나(각 카드의 현재 색)가 비용과 정확히 맞는가.
// 장수가 같아야 하고, 색 기호마다 그 색을 가진 카드를 하나씩 대응시킬 수 있어야 한다.
bool ena_pays(const std::vector<uint8_t>& cost, const std::vector<uint8_t>& colors);

// 가진 에나 중 일부로 낼 수 있는가
bool ena_can_pay(const std::vector<uint8_t>& cost, const std::vector<uint8_t>& colors);

}  // namespace wx
