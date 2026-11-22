#pragma once
// 작은 JSON 파서(덱 파일·DB의 JSON 칸·설정 파일용). 문자열·정수·참거짓·배열·객체만
#include <cctype>
#include <string>
#include <utility>
#include <variant>
#include <vector>

namespace wxtest {


struct Json;
using JsonObj = std::vector<std::pair<std::string, Json>>;  // 파일 순서 유지
using JsonArr = std::vector<Json>;
struct Json {
  std::variant<std::nullptr_t, long long, std::string, JsonArr, JsonObj, bool> v;
  const JsonObj* obj() const { return std::get_if<JsonObj>(&v); }
  const JsonArr* arr() const { return std::get_if<JsonArr>(&v); }
  const std::string* str() const { return std::get_if<std::string>(&v); }
  const long long* num() const { return std::get_if<long long>(&v); }
  const bool* boolean() const { return std::get_if<bool>(&v); }
  const Json* get(const std::string& k) const {
    if (auto* o = obj())
      for (auto& [key, val] : *o)
        if (key == k) return &val;
    return nullptr;
  }
};

struct Parser {
  const std::string& s;
  size_t i = 0;
  bool ok = true;

  void ws() {
    while (i < s.size() && std::isspace(static_cast<unsigned char>(s[i]))) ++i;
  }
  bool eat(char c) {
    ws();
    if (i < s.size() && s[i] == c) {
      ++i;
      return true;
    }
    return false;
  }
  std::string string() {
    std::string out;
    if (!eat('"')) {
      ok = false;
      return out;
    }
    while (i < s.size() && s[i] != '"') {
      if (s[i] == '\\' && i + 1 < s.size()) {
        const char e = s[++i];
        if (e == 'n') out += '\n';
        else if (e == 'u') {  // BMP만
          const unsigned cp = static_cast<unsigned>(std::stoul(s.substr(i + 1, 4), nullptr, 16));
          i += 4;
          if (cp < 0x80) out += static_cast<char>(cp);
          else if (cp < 0x800) {
            out += static_cast<char>(0xC0 | (cp >> 6));
            out += static_cast<char>(0x80 | (cp & 0x3F));
          } else {
            out += static_cast<char>(0xE0 | (cp >> 12));
            out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
            out += static_cast<char>(0x80 | (cp & 0x3F));
          }
        } else out += e;
        ++i;
      } else {
        out += s[i++];
      }
    }
    ++i;
    return out;
  }
  Json value() {
    ws();
    if (i >= s.size()) {
      ok = false;
      return {};
    }
    const char c = s[i];
    if (c == '"') return {string()};
    if (c == '{') {
      ++i;
      JsonObj o;
      if (eat('}')) return {o};
      do {
        std::string k = string();
        if (!eat(':')) ok = false;
        o.emplace_back(std::move(k), value());
      } while (ok && eat(','));
      if (!eat('}')) ok = false;
      return {o};
    }
    if (c == '[') {
      ++i;
      JsonArr a;
      if (eat(']')) return {a};
      do a.push_back(value());
      while (ok && eat(','));
      if (!eat(']')) ok = false;
      return {a};
    }
    if (c == '-' || std::isdigit(static_cast<unsigned char>(c))) {
      size_t n = 0;
      const long long v = std::stoll(s.substr(i), &n);
      i += n;
      return {v};
    }
    if (s.compare(i, 4, "true") == 0) {
      i += 4;
      return {true};
    }
    if (s.compare(i, 5, "false") == 0) {
      i += 5;
      return {false};
    }
    if (s.compare(i, 4, "null") == 0) {
      i += 4;
      return {};
    }
    ok = false;
    return {};
  }
};

inline bool parse_json(const std::string& text, Json& out) {
  Parser p{text};
  out = p.value();
  return p.ok;
}

}  // namespace wxtest
