#pragma once
#include <functional>
#include <memory>
#include <string>
#include <vector>

#include "duel.h"

namespace wx {

// 입력 기록 위에서 대전 하나를 돌린다. 상태를 바꾸는 입력(덱·시작·테스트 명령·응답)은 전부 여기를 거친다.
// 확정 후 되돌리기(테스트 모드)는 마지막 응답을 뺀 기록을 새 대전에서 다시 실행해서 만든다(설계: 결정론).
class Session {
 public:
  explicit Session(DuelConfig cfg);
  Session(const Session&) = delete;
  Session& operator=(const Session&) = delete;

  Duel& duel() { return *duel_; }

  // 상태를 바꾸는 명령. 실행하고 기록한다. f는 값만 잡아야 한다(다시 실행할 때 또 부른다)
  template <class F>
  auto command(F f) {
    log_.push_back({[f](Duel& d) { f(d); }, {}, false, duel_->request() != nullptr});
    return f(*duel_);
  }

  // 받아들여진 응답만 기록한다
  bool respond(Response r, std::string* why = nullptr);

  // 마지막 응답을 되돌려 그 요청을 다시 기다리는 상태로 만든다. 새 대전은 MSG_RESET부터 다시 보낸다.
  // 테스트 모드가 아니거나 되돌릴 응답이 없으면 false
  bool undo();

 private:
  struct Entry {
    std::function<void(Duel&)> cmd;
    Response res;
    bool is_response = false;
    bool at_request = false;  // 기록할 때 요청이 걸려 있었다 → 다시 실행할 때도 요청까지 진행한 뒤 적용
  };
  void process_to_request();

  DuelConfig cfg_;
  std::unique_ptr<Duel> duel_;
  std::vector<Entry> log_;
  bool replaying_ = false;
};

}  // namespace wx
