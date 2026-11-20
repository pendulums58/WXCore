#include "rng.h"

namespace wx {

namespace {
uint64_t rotl(uint64_t x, int k) { return (x << k) | (x >> (64 - k)); }

uint64_t splitmix64(uint64_t& x) {
  uint64_t z = (x += 0x9e3779b97f4a7c15ULL);
  z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
  z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
  return z ^ (z >> 31);
}
}  // namespace

void Rng::reseed(uint64_t seed) {
  for (auto& s : s_) s = splitmix64(seed);
}

uint64_t Rng::next_u64() {
  const uint64_t result = rotl(s_[1] * 5, 7) * 9;
  const uint64_t t = s_[1] << 17;
  s_[2] ^= s_[0];
  s_[3] ^= s_[1];
  s_[1] ^= s_[2];
  s_[0] ^= s_[3];
  s_[2] ^= t;
  s_[3] = rotl(s_[3], 45);
  return result;
}

// Lemire 방식(편향 없음)
uint32_t Rng::below(uint32_t n) {
  if (n == 0) return 0;
  uint64_t m = static_cast<uint64_t>(next_u32()) * n;
  uint32_t l = static_cast<uint32_t>(m);
  if (l < n) {
    const uint32_t t = (0u - n) % n;
    while (l < t) {
      m = static_cast<uint64_t>(next_u32()) * n;
      l = static_cast<uint32_t>(m);
    }
  }
  return static_cast<uint32_t>(m >> 32);
}

}  // namespace wx
