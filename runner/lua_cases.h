#pragma once
#include <string>

// dir 안의 *.lua 케이스를 돌린다. run/failed에 더한다. 불러오기 실패한 파일 수를 돌려준다.
int run_lua_cases(const std::string& dir, const char* filter, int& run, int& failed);
