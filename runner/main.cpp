#include <cstdio>
#include <cstring>

#ifdef _WIN32
#include <windows.h>
#endif

#include "test.h"

// 사용법: wx_runner [이름 일부]  — 인자가 있으면 이름에 그 문자열이 든 케이스만
int main(int argc, char** argv) {
#ifdef _WIN32
  SetConsoleOutputCP(CP_UTF8);
#endif
  const char* filter = argc > 1 ? argv[1] : nullptr;
  int run = 0, failed = 0;
  for (const auto& c : wxtest::registry()) {
    if (filter && !std::strstr(c.name, filter)) continue;
    const int before = wxtest::failures();
    c.fn();
    ++run;
    if (wxtest::failures() != before) {
      ++failed;
      std::printf("FAIL %s  [%s]\n", c.name, c.ref);
    }
  }
  std::printf("%d/%d 케이스 통과\n", run - failed, run);
  return failed == 0 ? 0 : 1;
}
