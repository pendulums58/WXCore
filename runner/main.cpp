#include <cstdio>
#include <cstdlib>
#include <cstring>

#ifdef _WIN32
#include <windows.h>
#endif

#include "fuzz.h"
#include "lua_cases.h"
#include "test.h"

// 사용법: wx_runner [이름 일부]  — 인자가 있으면 이름(또는 Lua 파일 이름)에 그 문자열이 든 케이스만
//         wx_runner --fuzz [판 수] [시작 시드] [--no-undo] [-v] [-t]  — 랜덤 AI 대전
int main(int argc, char** argv) {
#ifdef _WIN32
  SetConsoleOutputCP(CP_UTF8);
#endif
  if (argc > 1 && std::strcmp(argv[1], "--fuzz") == 0) {
    wxfuzz::Options o;
    int pos = 0;
    for (int i = 2; i < argc; ++i) {
      if (std::strcmp(argv[i], "--no-undo") == 0)
        o.undo = false;
      else if (std::strcmp(argv[i], "-v") == 0)
        o.verbose = true;
      else if (std::strcmp(argv[i], "-t") == 0)
        o.trace = o.verbose = true;
      else if (pos++ == 0)
        o.games = std::atoi(argv[i]);
      else
        o.seed = std::strtoull(argv[i], nullptr, 10);
    }
    const auto s = wxfuzz::run(o);
    std::printf("fuzz %d판: 실패 %d, 승리 p0 %d / p1 %d, 평균 %.1f턴, 응답 %llu, 되돌리기 %llu\n", s.games, s.failed,
                s.wins[0], s.wins[1], s.games - s.failed ? double(s.turns) / (s.games - s.failed) : 0.0,
                static_cast<unsigned long long>(s.responses), static_cast<unsigned long long>(s.undos));
    return s.failed == 0 ? 0 : 1;
  }
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
  const int load_errors = run_lua_cases(WX_CASES_DIR, filter, run, failed);
  std::printf("%d/%d 케이스 통과\n", run - failed, run);
  return failed == 0 && load_errors == 0 ? 0 : 1;
}
