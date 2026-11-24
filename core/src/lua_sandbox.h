#pragma once
// 카드·포맷 스크립트용 Lua 환경. 오리카 팩은 저장소로 받은 남의 코드이므로 파일·프로세스·디버그 기능을 열지 않는다
// (YGOPro·EDOPro처럼 os·io·debug·package·coroutine 없음). 바이트코드도 읽지 않는다
#include <string>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

namespace wx {

inline void open_safe_libs(lua_State* L) {
  static const luaL_Reg libs[] = {{LUA_GNAME, luaopen_base},
                                  {LUA_STRLIBNAME, luaopen_string},
                                  {LUA_TABLIBNAME, luaopen_table},
                                  {LUA_MATHLIBNAME, luaopen_math},
                                  {LUA_UTF8LIBNAME, luaopen_utf8}};
  for (const luaL_Reg& lib : libs) {
    luaL_requiref(L, lib.name, lib.func, 1);
    lua_pop(L, 1);
  }
  // 파일·바이트코드를 읽는 것, 결과가 실행마다 달라지는 것
  for (const char* name : {"dofile", "loadfile", "load", "collectgarbage"}) {
    lua_pushnil(L);
    lua_setglobal(L, name);
  }
  lua_getglobal(L, LUA_STRLIBNAME);
  lua_pushnil(L);
  lua_setfield(L, -2, "dump");
  lua_pop(L, 1);
}

// 텍스트 스크립트만 읽는다(바이트코드 거부)
inline int load_text(lua_State* L, const std::string& code, const char* name) {
  return luaL_loadbufferx(L, code.data(), code.size(), name, "t");
}

}  // namespace wx
