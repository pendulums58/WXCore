#pragma once
// 랜덤 AI 무작위 대전(설계: 테스트와 AI). 공개 C API만 쓴다.
#include <cstdint>
#include <string>
#include <vector>

namespace wxfuzz {

struct Options {
  int games = 200;
  uint64_t seed = 1;
  bool undo = true;     // 가끔 wx_test_undo를 섞는다(테스트 모드로 만든다)
  bool verbose = false;  // 판마다 시드를 찍는다
  bool trace = false;    // 메시지·응답을 전부 찍는다
};

struct Summary {
  int games = 0, failed = 0;
  int wins[2] = {0, 0};
  uint64_t turns = 0, responses = 0, undos = 0;
};

// 한 판. 실패하면 이유를 채우고 false
bool play(uint64_t seed, bool undo, std::string& why, Summary& sum, std::vector<uint8_t>* all_view = nullptr);

// 여러 판. 실패한 판의 시드와 이유를 찍는다
Summary run(const Options& opt);

}  // namespace wxfuzz
