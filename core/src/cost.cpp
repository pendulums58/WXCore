#include "cost.h"

#include "carddata.h"

namespace wx {

namespace {
uint8_t color_of_letter(char ch) {
  switch (ch) {
    case 'W': return COLOR_WHITE;
    case 'R': return COLOR_RED;
    case 'U': return COLOR_BLUE;
    case 'G': return COLOR_GREEN;
    case 'B': return COLOR_BLACK;
    default: return 0;  // C
  }
}

// 색 기호를 카드에 하나씩 대응(이분 매칭, 증가 경로)
bool augment(const std::vector<uint8_t>& sym, const std::vector<uint8_t>& colors, size_t s,
             std::vector<int>& owner, std::vector<bool>& seen) {
  for (size_t c = 0; c < colors.size(); ++c) {
    if (!(colors[c] & sym[s]) || seen[c]) continue;
    seen[c] = true;
    if (owner[c] < 0 || augment(sym, colors, static_cast<size_t>(owner[c]), owner, seen)) {
      owner[c] = static_cast<int>(s);
      return true;
    }
  }
  return false;
}

bool colored_match(const std::vector<uint8_t>& cost, const std::vector<uint8_t>& colors) {
  std::vector<uint8_t> sym;
  for (uint8_t s : cost)
    if (s) sym.push_back(s);
  std::vector<int> owner(colors.size(), -1);
  for (size_t s = 0; s < sym.size(); ++s) {
    std::vector<bool> seen(colors.size(), false);
    if (!augment(sym, colors, s, owner, seen)) return false;
  }
  return true;
}
}  // namespace

std::vector<uint8_t> parse_ena_cost(const std::string& cost) {
  std::vector<uint8_t> out;
  uint8_t cur = 0;
  bool in = false, colorless = false;
  for (char ch : cost) {
    if (ch == '{') {
      in = true;
      cur = 0;
      colorless = false;
    } else if (ch == '}') {
      if (in) out.push_back(colorless ? 0 : cur);
      in = false;
    } else if (in && ch != '/') {
      if (ch == 'C') colorless = true;
      cur |= color_of_letter(ch);
    }
  }
  return out;
}

std::string reduce_ena_cost(std::string cost, const std::string& symbols) {
  for (size_t i = 0; i < symbols.size();) {
    const size_t end = symbols.find('}', i);
    if (end == std::string::npos) break;
    const std::string sym = symbols.substr(i, end - i + 1);
    if (const size_t at = cost.find(sym); at != std::string::npos) cost.erase(at, sym.size());
    i = end + 1;
  }
  return cost;
}

bool ena_pays(const std::vector<uint8_t>& cost, const std::vector<uint8_t>& colors) {
  return colors.size() == cost.size() && colored_match(cost, colors);
}

bool ena_can_pay(const std::vector<uint8_t>& cost, const std::vector<uint8_t>& colors) {
  return colors.size() >= cost.size() && colored_match(cost, colors);
}

}  // namespace wx
