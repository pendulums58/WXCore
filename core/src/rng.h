#pragma once
#include <cstdint>
#include <utility>
#include <vector>

namespace wx {

// 코어 내장 PRNG. xoshiro256** + splitmix64 시드 확장.
// std 분포 함수는 구현마다 결과가 달라서 쓰지 않는다. 범위 변환도 직접 한다.
class Rng {
 public:
  explicit Rng(uint64_t seed = 0) { reseed(seed); }

  void reseed(uint64_t seed);
  uint64_t next_u64();
  uint32_t next_u32() { return static_cast<uint32_t>(next_u64() >> 32); }

  // [0, n) 균등. n == 0이면 0.
  uint32_t below(uint32_t n);

  template <class T>
  void shuffle(std::vector<T>& v) {
    for (size_t i = v.size(); i > 1; --i) {
      size_t j = below(static_cast<uint32_t>(i));
      std::swap(v[i - 1], v[j]);
    }
  }

 private:
  uint64_t s_[4];
};

}  // namespace wx
