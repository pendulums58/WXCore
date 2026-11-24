#include "deck_check.h"

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <sstream>

#include "lua_sandbox.h"

namespace wxtest {

namespace {

bool read_file(const std::string& path, std::string& out) {
  std::ifstream f(path, std::ios::binary);
  if (!f) return false;
  std::stringstream ss;
  ss << f.rdbuf();
  out = ss.str();
  return true;
}

CardDb* g_db = nullptr;  // 검사 하나 동안만(Lua 함수에서 쓴다)

// Deck.NameHasFormat(name_key, bits): 같은 이름(카드 표의 name_key)에 bits 포맷 아이콘이 붙은 인쇄본이 있는가
int l_name_has_format(lua_State* L) {
  lua_pushboolean(L, g_db->name_has_format(static_cast<wx::Cid>(luaL_checkinteger(L, 1)),
                                           static_cast<uint32_t>(luaL_checkinteger(L, 2))));
  return 1;
}

// Deck.HasFormatLrig0(color, lrig_type, bits): bits 아이콘이 붙은 레벨 0 루리그 중 색과 루리그 타입(ID)이 같은 것이 있는가
int l_has_format_lrig0(lua_State* L) {
  const auto color = static_cast<uint8_t>(luaL_checkinteger(L, 1));
  const auto type = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  const auto bits = static_cast<uint32_t>(luaL_checkinteger(L, 3));
  bool found = false;
  for (const auto& e : g_db->all_cards()) {
    if (!(e.type & wx::TYPE_LRIG) || e.level != 0 || e.color != color || !(e.formats & bits)) continue;
    if (std::find(e.lrig_types.begin(), e.lrig_types.end(), type) != e.lrig_types.end()) {
      found = true;
      break;
    }
  }
  lua_pushboolean(L, found);
  return 1;
}

// Deck.LrigTypeName(id): 메시지용 이름
int l_lrig_type_name(lua_State* L) {
  lua_pushstring(L, g_db->lrig_type_name(static_cast<uint32_t>(luaL_checkinteger(L, 1))).c_str());
  return 1;
}

void push_card(lua_State* L, CardDb& db, wx::Cid cid) {
  const CardEntry* e = db.entry(cid);
  lua_newtable(L);
  lua_pushinteger(L, cid);
  lua_setfield(L, -2, "cid");
  if (!e) return;
  auto set_str = [&](const char* k, const std::string& v) {
    lua_pushstring(L, v.c_str());
    lua_setfield(L, -2, k);
  };
  auto set_int = [&](const char* k, long long v) {
    lua_pushinteger(L, v);
    lua_setfield(L, -2, k);
  };
  auto set_bool = [&](const char* k, bool v) {
    lua_pushboolean(L, v);
    lua_setfield(L, -2, k);
  };
  set_int("name_key", e->name_key());  // 「같은 이름」 판정용(alias 또는 cid)
  set_int("name", e->name_key());  // 옛 formats/*.lua 호환: 예전엔 일본어 이름 문자열을 같은 키로 썼다
  set_str("label", e->name);       // 메시지용
  set_int("level", e->level);
  set_int("color", e->color);
  set_int("formats", static_cast<long long>(e->formats));
  set_bool("life_burst", e->life_burst);
  set_bool("lrig", e->type & wx::TYPE_LRIG);
  set_bool("assist", e->type & wx::TYPE_ASSIST_LRIG);
  set_bool("arts", e->type & wx::TYPE_ARTS);
  set_bool("piece", e->type & wx::TYPE_PIECE);
  set_bool("key", e->type & wx::TYPE_KEY);
  set_bool("resona", e->type & wx::TYPE_RESONA);
  set_bool("signi", e->type & wx::TYPE_SIGNI);
  set_bool("spell", e->type & wx::TYPE_SPELL);
  lua_newtable(L);  // 루리그 타입 ID
  for (size_t i = 0; i < e->lrig_types.size(); ++i) {
    lua_pushinteger(L, e->lrig_types[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  lua_setfield(L, -2, "lrig_types");
}

void push_cards(lua_State* L, CardDb& db, const std::vector<wx::Cid>& cids) {
  lua_newtable(L);
  for (size_t i = 0; i < cids.size(); ++i) {
    push_card(L, db, cids[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
}

}  // namespace

DeckCheck check_deck(CardDb& db, const DeckFile& deck) {
  DeckCheck out;
  // 저장소·개인 작업물의 formats/가 먼저, 없으면 최상위 formats/(동봉 기본값, data_dirs의 맨 앞)
  auto locate = [](const std::string& name) {
    const std::string found = find_data_file("formats", name);
    return found.empty() ? data_dir() + "/formats/" + name : found;
  };
  std::string common, script;
  if (deck.format.empty()) {
    out.error = "덱 포맷이 비었음";
    return out;
  }
  // 덱 파일은 남에게서 온다(게스트 덱). 포맷 이름으로 formats/ 밖의 파일을 가리키지 못하게
  for (const char ch : deck.format)
    if (!std::isalnum(static_cast<unsigned char>(ch)) && ch != '_' && ch != '-') {
      out.error = "덱 포맷 이름에 쓸 수 없는 글자가 있음";
      return out;
    }
  if (!read_file(locate("common.lua"), common) || !read_file(locate(deck.format + ".lua"), script)) {
    out.error = "formats/" + deck.format + ".lua 를 못 읽음";
    return out;
  }
  lua_State* L = luaL_newstate();
  wx::open_safe_libs(L);
  g_db = &db;
  // Deck 표: 상수와 C++ 도우미
  lua_newtable(L);
  lua_pushinteger(L, kFormatKey);
  lua_setfield(L, -2, "FORMAT_KEY");
  lua_pushinteger(L, kFormatDiva);
  lua_setfield(L, -2, "FORMAT_DIVA");
  lua_pushcfunction(L, l_name_has_format);
  lua_setfield(L, -2, "NameHasFormat");
  lua_pushcfunction(L, l_has_format_lrig0);
  lua_setfield(L, -2, "HasFormatLrig0");
  lua_pushcfunction(L, l_lrig_type_name);
  lua_setfield(L, -2, "LrigTypeName");
  lua_setglobal(L, "Deck");

  auto run = [&](const std::string& code, const std::string& name) {
    if (wx::load_text(L, code, ("@formats/" + name).c_str()) || lua_pcall(L, 0, 0, 0)) {
      out.error = lua_tostring(L, -1) ? lua_tostring(L, -1) : "Lua 오류";
      return false;
    }
    return true;
  };
  if (run(common, "common.lua") && run(script, deck.format + ".lua")) {
    // check(deck) -> 문제 목록(문자열 배열)
    lua_getglobal(L, "check");
    lua_newtable(L);
    lua_pushstring(L, deck.format.c_str());
    lua_setfield(L, -2, "format");
    push_cards(L, db, deck.main);
    lua_setfield(L, -2, "main");
    push_cards(L, db, deck.lrig);
    lua_setfield(L, -2, "lrig");
    lua_newtable(L);  // start = {center = 카드, assist = {카드...}}
    if (deck.start_center) {
      push_card(L, db, deck.start_center);
      lua_setfield(L, -2, "center");
    }
    push_cards(L, db, deck.start_assists);
    lua_setfield(L, -2, "assist");
    lua_setfield(L, -2, "start");
    if (lua_pcall(L, 1, 1, 0)) {
      out.error = lua_tostring(L, -1) ? lua_tostring(L, -1) : "Lua 오류";
    } else if (lua_istable(L, -1)) {
      const lua_Integer n = static_cast<lua_Integer>(lua_rawlen(L, -1));
      for (lua_Integer i = 1; i <= n; ++i) {
        lua_rawgeti(L, -1, i);
        if (const char* s = lua_tostring(L, -1)) out.problems.push_back(s);
        lua_pop(L, 1);
      }
      out.ok = out.problems.empty();
    } else {
      out.error = "check()가 목록을 돌려주지 않음";
    }
  }
  lua_close(L);
  g_db = nullptr;
  return out;
}

}  // namespace wxtest
