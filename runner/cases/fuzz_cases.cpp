// 랜덤 대전을 조금씩 돌려 둔다. 많이 돌릴 때는 wx_runner --fuzz
#include "fuzz.h"
#include "test.h"

TEST_CASE("fuzz: 랜덤 AI 대전 30판이 크래시·무한 루프 없이 끝난다", "설계: 테스트와 AI") {
  wxfuzz::Options o;
  o.games = 30;
  o.seed = 1000;
  const auto s = wxfuzz::run(o);
  CHECK(s.failed == 0);
  CHECK(s.wins[0] + s.wins[1] == 30);
  CHECK(s.undos > 0);
}

TEST_CASE("fuzz: 같은 시드면 메시지 바이트가 같다(되돌리기 섞어도)", "설계: 결정론") {
  for (uint64_t seed : {7ull, 8ull}) {
    std::vector<uint8_t> a, b;
    std::string why;
    wxfuzz::Summary s;
    CHECK(wxfuzz::play(seed, true, why, s, &a));
    CHECK(wxfuzz::play(seed, true, why, s, &b));
    CHECK(!a.empty() && a == b);
  }
}
