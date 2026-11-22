#pragma once
// 덱 검증. 포맷마다 Lua 스크립트(formats/<format>.lua) 하나로 짠다(설계: 포맷과 덱 검증).
// 스크립트는 formats/common.lua의 공통 검사(장 수·같은 이름·시작 루리그 등)를 쓰고 포맷만의 카드 범위를 더한다.
#include <string>
#include <vector>

#include "card_db.h"

namespace wxtest {

struct DeckCheck {
  bool ok = false;                    // 스크립트가 돌았고 문제가 없다
  std::vector<std::string> problems;  // 사람이 읽는 문제 목록
  std::string error;                  // 스크립트를 못 돌렸으면 이유
};

// deck.format이 비었거나 스크립트가 없으면 error가 찬다
DeckCheck check_deck(CardDb& db, const DeckFile& deck);

}  // namespace wxtest
