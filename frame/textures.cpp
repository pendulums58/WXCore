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

namespace {
constexpr size_t kMaxCards = 300;  // 이만큼 넘게 쌓이면 오래 안 쓴 것부터 지운다
}

Textures::Textures(SDL_Renderer* r) : renderer_(r) { find_dirs(); }

void Textures::find_dirs() {
  dirs_.clear();
  // 데이터 폴더의 pics/를 우선순위가 높은 것부터
  const auto dirs = wxtest::data_dirs();
  for (auto d = dirs.rbegin(); d != dirs.rend(); ++d)
    if (fs::is_directory(fs::path(*d) / "pics")) dirs_.push_back((fs::path(*d) / "pics").string());
}

Textures::~Textures() {
  for (auto& [key, p] : cache_) destroy(p.tex);
  for (auto& [name, t] : files_) destroy(t);
}

void Textures::destroy(const Texture& t) {
  if (t.id) SDL_DestroyTexture(reinterpret_cast<SDL_Texture*>(t.id));
}

void Textures::begin_frame() {
  ++frame_;
  if (reload_) {
    reload_ = false;
    for (auto& [key, p] : cache_) destroy(p.tex);
    cache_.clear();
    find_dirs();
    return;
  }
  if (cache_.size() <= kMaxCards) return;
  // 지난 프레임에 쓴 것은 남긴다. 3/4로 줄인다
  std::vector<std::pair<uint64_t, std::pair<uint32_t, int>>> order;
  for (const auto& [key, p] : cache_)
    if (p.used + 1 < frame_) order.emplace_back(p.used, key);
  std::sort(order.begin(), order.end());
  for (const auto& [used, key] : order) {
    if (cache_.size() <= kMaxCards * 3 / 4) break;
    destroy(cache_[key].tex);
    cache_.erase(key);
  }
}

const Texture& Textures::card(uint32_t cid, int idx) {
  if (idx < 1) idx = 1;
  auto it = cache_.find({cid, idx});
  if (it != cache_.end()) {
    it->second.used = frame_;
    if (!it->second.tex.id && idx > 1) return card(cid, 1);
    return it->second.tex;
  }
  // 판본 1 = <cid>, 판본 n = <cid>_<n>(설계: 이미지 파일)
  const std::string stem = std::to_string(cid) + (idx > 1 ? "_" + std::to_string(idx) : "");
  Texture t;
  for (const auto& d : dirs_) {
    for (const char* ext : {".jpg", ".png"}) {
      const std::string path = d + "/" + stem + ext;
      if (fs::exists(path)) t = load(path);
      if (t.id) break;
    }
    if (t.id) break;
  }
  cache_[{cid, idx}] = {t, frame_};
  if (!t.id && idx > 1) return card(cid, 1);
  return cache_[{cid, idx}].tex;
}

const Texture& Textures::file(const std::string& name) {
  auto it = files_.find(name);
  if (it != files_.end()) return it->second;
  Texture t;
  for (const char* ext : {".jpg", ".png"}) {
    const std::string path = wxtest::data_dir() + "/textures/" + name + ext;
    if (fs::exists(path)) t = load(path);
    if (t.id) break;
  }
  return files_[name] = t;
}

const Texture& Textures::path(const std::string& full) {
  auto it = files_.find(full);
  if (it != files_.end()) return it->second;
  return files_[full] = load(full);
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
    t.id = reinterpret_cast<ImTextureID>(tex);
    t.w = w;
    t.h = h;
  }
  stbi_image_free(px);
  return t;
}

}  // namespace wxframe
