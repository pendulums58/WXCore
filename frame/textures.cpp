#include "textures.h"

#include <SDL3/SDL.h>

#include <algorithm>
#include <filesystem>

#include "card_db.h"

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_JPEG
#define STBI_ONLY_PNG
#include <stb_image.h>

namespace wxframe {

namespace fs = std::filesystem;

Textures::Textures(SDL_Renderer* r) : renderer_(r) {
  const fs::path root = wxtest::data_dir();
  dirs_.push_back((root / "pics").string());
  // 확장 폴더 안의 pics/는 폴더 이름 순으로
  for (const char* group : {"expansions", "repositories"}) {
    std::vector<std::string> found;
    std::error_code ec;
    for (const auto& e : fs::directory_iterator(root / group, ec))
      if (e.is_directory() && fs::is_directory(e.path() / "pics")) found.push_back((e.path() / "pics").string());
    std::sort(found.begin(), found.end());
    dirs_.insert(dirs_.end(), found.begin(), found.end());
  }
}

Textures::~Textures() {
  for (SDL_Texture* t : owned_) SDL_DestroyTexture(t);
}

const Texture& Textures::card(uint32_t cid) {
  auto it = cache_.find(cid);
  if (it != cache_.end()) return it->second;
  Texture t;
  for (const auto& d : dirs_) {
    for (const char* ext : {".jpg", ".png"}) {
      const std::string path = d + "/" + std::to_string(cid) + ext;
      if (fs::exists(path)) t = load(path);
      if (t.id) break;
    }
    if (t.id) break;
  }
  return cache_[cid] = t;
}

Texture Textures::load(const std::string& path) {
  Texture t;
  int w = 0, h = 0, n = 0;
  stbi_uc* px = stbi_load(path.c_str(), &w, &h, &n, 4);
  if (!px) return t;
  SDL_Texture* tex = SDL_CreateTexture(renderer_, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STATIC, w, h);
  if (tex) {
    SDL_UpdateTexture(tex, nullptr, px, w * 4);
    SDL_SetTextureScaleMode(tex, SDL_SCALEMODE_LINEAR);
    owned_.push_back(tex);
    t.id = reinterpret_cast<ImTextureID>(tex);
    t.w = w;
    t.h = h;
  }
  stbi_image_free(px);
  return t;
}

}  // namespace wxframe
