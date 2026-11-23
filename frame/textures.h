#pragma once
// 카드 이미지 텍스처. YGOPro처럼 pics/<cid>.jpg를 찾는다. 판본 2부터는 pics/<cid>_<idx>.jpg(없으면 기본 그림).
// 찾는 순서: expansions/pics/ → repositories/*/pics/ → pics/ (데이터 폴더 기준, data_dirs의 역순). 처음 쓸 때 읽는다.
// 화면 그림(뒷면 cover.jpg·cover_lrig.jpg, 배경 bg.jpg)은 textures/에서 찾는다. 없으면 프레임이 직접 그린다.
#include <imgui.h>

#include <cstdint>
#include <map>
#include <string>
#include <vector>

struct SDL_Renderer;
struct SDL_Texture;

namespace wxframe {

struct Texture {
  ImTextureID id = 0;  // 0이면 없음
  int w = 0, h = 0;
};

class Textures {
 public:
  explicit Textures(SDL_Renderer* r);
  ~Textures();
  Textures(const Textures&) = delete;
  Textures& operator=(const Textures&) = delete;

  // 판본 idx(1부터)의 그림. 그 판본 그림이 없으면 기본 그림, 그것도 없으면 id 0. 실패도 기억해서 다시 찾지 않는다
  const Texture& card(uint32_t cid, int idx = 1);
  // textures/<name>(.jpg 또는 .png). 없으면 id 0
  const Texture& file(const std::string& name);
  // 경로로(텍스트 아이콘 등). 없으면 id 0
  const Texture& path(const std::string& full);

 private:
  Texture load(const std::string& path);

  SDL_Renderer* renderer_;
  std::vector<std::string> dirs_;
  std::map<std::pair<uint32_t, int>, Texture> cache_;
  std::map<std::string, Texture> files_;
  std::vector<SDL_Texture*> owned_;
};

}  // namespace wxframe
