#include "session.h"

namespace wx {

Session::Session(DuelConfig cfg) : cfg_(std::move(cfg)) {
  // 다시 실행하는 동안의 로그는 이미 한 번 나간 것이라 버린다
  if (cfg_.log) {
    LogFn inner = std::move(cfg_.log);
    cfg_.log = [this, inner](const std::string& m) {
      if (!replaying_) inner(m);
    };
  }
  duel_ = std::make_unique<Duel>(cfg_);
}

bool Session::respond(Response r, std::string* why) {
  if (!duel_->respond(r, why)) return false;
  Entry e;
  e.res = std::move(r);
  e.is_response = true;
  e.at_request = true;
  log_.push_back(std::move(e));
  return true;
}

void Session::process_to_request() {
  while (!duel_->request() && duel_->process() == Duel::Result::Continue) {
  }
}

bool Session::undo() {
  if (!cfg_.test_mode) return false;
  size_t last = log_.size();
  while (last > 0 && !log_[last - 1].is_response) --last;
  if (last == 0) return false;
  log_.resize(last - 1);

  replaying_ = true;
  DuelConfig cfg = cfg_;
  cfg.reset_message = true;
  duel_ = std::make_unique<Duel>(cfg);
  for (const Entry& e : log_) {
    if (e.at_request) process_to_request();
    if (e.is_response)
      duel_->respond(e.res);
    else
      e.cmd(*duel_);
  }
  process_to_request();
  replaying_ = false;
  return true;
}

}  // namespace wx
