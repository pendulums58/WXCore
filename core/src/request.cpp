#include "request.h"

#include <algorithm>

namespace wx {

bool validate(const Request& req, const Response& res, std::string& why) {
  if (res.cancel) {
    if (req.cancelable) return true;
    why = "취소할 수 없는 선택";
    return false;
  }
  const auto& p = res.picks;
  if (p.size() < req.min || p.size() > req.max) {
    why = "개수가 맞지 않음";
    return false;
  }
  for (size_t i = 0; i < p.size(); ++i) {
    if (req.accept ? !req.accept(p[i]) : std::find(req.options.begin(), req.options.end(), p[i]) == req.options.end()) {
      why = "후보에 없는 선택";
      return false;
    }
    if (std::find(p.begin(), p.begin() + i, p[i]) != p.begin() + i) {
      why = "같은 것을 두 번 고름";
      return false;
    }
  }
  if (req.check && !req.check(p, why)) return false;
  return true;
}

}  // namespace wx
