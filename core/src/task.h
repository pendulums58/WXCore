#pragma once
// 진행 엔진용 코루틴. 게임 흐름을 위에서 아래로 쓰고, 입력이 필요한 곳에서 co_await로 멈춘다.
// 가장 안쪽 코루틴이 멈추면 process()까지 제어가 돌아오고(pull 모델),
// 응답이 들어오면 멈춘 지점부터 다시 이어 간다. 스레드는 쓰지 않는다.
#include <coroutine>
#include <exception>
#include <optional>
#include <utility>

namespace wx {

namespace detail {
struct PromiseBase {
  std::coroutine_handle<> continuation;
  std::exception_ptr error;

  std::suspend_always initial_suspend() noexcept { return {}; }
  struct Final {
    bool await_ready() noexcept { return false; }
    template <class P>
    std::coroutine_handle<> await_suspend(std::coroutine_handle<P> h) noexcept {
      auto c = h.promise().continuation;
      return c ? c : std::noop_coroutine();
    }
    void await_resume() noexcept {}
  };
  Final final_suspend() noexcept { return {}; }
  void unhandled_exception() { error = std::current_exception(); }
};
}  // namespace detail

template <class T>
struct TaskPromise;

template <class T = void>
class [[nodiscard]] Task {
 public:
  using promise_type = TaskPromise<T>;
  using handle_type = std::coroutine_handle<promise_type>;

  Task() = default;
  explicit Task(handle_type h) : h_(h) {}
  Task(Task&& o) noexcept : h_(std::exchange(o.h_, {})) {}
  Task& operator=(Task&& o) noexcept {
    if (this != &o) {
      if (h_) h_.destroy();
      h_ = std::exchange(o.h_, {});
    }
    return *this;
  }
  Task(const Task&) = delete;
  ~Task() {
    if (h_) h_.destroy();
  }

  handle_type handle() const { return h_; }

  bool await_ready() const noexcept { return false; }
  std::coroutine_handle<> await_suspend(std::coroutine_handle<> caller) noexcept {
    h_.promise().continuation = caller;
    return h_;
  }
  T await_resume() {
    if (h_.promise().error) std::rethrow_exception(h_.promise().error);
    if constexpr (!std::is_void_v<T>) return std::move(*h_.promise().value);
  }

 private:
  handle_type h_;
};

template <class T>
struct TaskPromise : detail::PromiseBase {
  std::optional<T> value;
  Task<T> get_return_object() { return Task<T>(std::coroutine_handle<TaskPromise>::from_promise(*this)); }
  void return_value(T v) { value = std::move(v); }
};

template <>
struct TaskPromise<void> : detail::PromiseBase {
  Task<void> get_return_object() {
    return Task<void>(std::coroutine_handle<TaskPromise>::from_promise(*this));
  }
  void return_void() {}
};

}  // namespace wx
