#include "rng.h"
#include "test.h"

using namespace wx;

// 기준값은 파이썬 독립 구현으로 뽑았다. 컴파일러가 바뀌어도 같아야 한다.
TEST_CASE("rng: xoshiro256** 기준값", "설계: 결정론") {
  Rng r(12345);
  CHECK(r.next_u64() == 0xbe6a36374160d49bULL);
  CHECK(r.next_u64() == 0x214aaa0637a688c6ULL);
  CHECK(r.next_u64() == 0xf69d16de9954d388ULL);
}

TEST_CASE("rng: below 기준값", "설계: 결정론") {
  Rng r(42);
  const uint32_t expect[] = {3, 15, 27, 36, 39, 30, 28, 34};
  for (uint32_t e : expect) CHECK(r.below(40) == e);
}

TEST_CASE("rng: 같은 시드면 같은 셔플", "설계: 결정론") {
  std::vector<int> a, b;
  for (int i = 0; i < 40; ++i) a.push_back(i);
  b = a;
  Rng r1(7), r2(7);
  r1.shuffle(a);
  r2.shuffle(b);
  CHECK(a == b);
}
