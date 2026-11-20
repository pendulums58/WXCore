#pragma once
// 최소 테스트 하네스. 케이스마다 이름과 근거(FAQ 번호, 용어집 항목)를 단다.
#include <cstdio>
#include <functional>
#include <vector>

namespace wxtest {

struct Case {
  const char* name;
  const char* ref;  // 근거
  std::function<void()> fn;
};

inline std::vector<Case>& registry() {
  static std::vector<Case> r;
  return r;
}

inline int& failures() {
  static int f = 0;
  return f;
}

struct Registrar {
  Registrar(const char* name, const char* ref, std::function<void()> fn) {
    registry().push_back({name, ref, std::move(fn)});
  }
};

}  // namespace wxtest

#define WX_CAT2(a, b) a##b
#define WX_CAT(a, b) WX_CAT2(a, b)

#define TEST_CASE(name, ref)                                              \
  static void WX_CAT(wx_case_, __LINE__)();                               \
  static wxtest::Registrar WX_CAT(wx_reg_, __LINE__)(name, ref,           \
                                                     WX_CAT(wx_case_, __LINE__)); \
  static void WX_CAT(wx_case_, __LINE__)()

#define CHECK(expr)                                                       \
  do {                                                                    \
    if (!(expr)) {                                                        \
      ++wxtest::failures();                                               \
      std::printf("    CHECK 실패 %s:%d: %s\n", __FILE__, __LINE__, #expr); \
    }                                                                     \
  } while (0)
