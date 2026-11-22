#include "icon_text.h"

#include <filesystem>
#include <fstream>
#include <sstream>

#include "json.h"

namespace wxframe {

int IconMap::load(const std::vector<std::string>& dirs) {
  int n = 0;
  for (const auto& d : dirs) {
    const std::filesystem::path icons = std::filesystem::path(d) / "icons";
    std::ifstream f(icons / "icons.json", std::ios::binary);
    if (!f) continue;
    std::stringstream ss;
    ss << f.rdbuf();
    if (add(ss.str(), icons.string())) ++n;
  }
  return n;
}

bool IconMap::add(const std::string& json, const std::string& icons_dir, bool check_files) {
  wxtest::Json j;
  if (!wxtest::parse_json(json, j) || !j.obj()) return false;
  for (const auto& [token, v] : *j.obj()) {
    if (token.empty() || token[0] == '_' || !v.str()) continue;  // "_note" 같은 설명 칸
    const std::string path = (std::filesystem::path(icons_dir) / *v.str()).string();
    if (check_files && !std::filesystem::exists(path)) continue;
    map_[token] = path;
  }
  return true;
}

void IconMap::clear() { map_.clear(); }

std::vector<IconMap::Segment> IconMap::split(const std::string& text) const {
  std::vector<Segment> out;
  std::string plain;
  size_t i = 0;
  while (i < text.size()) {
    const std::string* best = nullptr;
    const std::string* image = nullptr;
    for (const auto& [token, path] : map_)
      if (text.compare(i, token.size(), token) == 0 && (!best || token.size() > best->size())) {
        best = &token;
        image = &path;
      }
    if (!best) {
      plain += text[i++];
      continue;
    }
    if (!plain.empty()) out.push_back({std::move(plain), {}});
    plain.clear();
    out.push_back({{}, *image});
    i += best->size();
  }
  if (!plain.empty()) out.push_back({std::move(plain), {}});
  return out;
}

}  // namespace wxframe
