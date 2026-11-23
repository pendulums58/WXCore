-- 테스트 덱(decks/*.json)과 실제 카드 DB

case("deck: 테스트 덱 두 개를 DB에서 읽는다", "AGENTS.md: 작업 순서 3", function(t)
  t:start{db = true}
  t:expect(t:no("WXDi-D01-012") ~= nil, "카드 번호 → cid")
  t:expect(t:no("NO-SUCH-001") == nil)
  local ok, d = t:deck_file(0, "WXDi-D01_ancient_surprise")
  t:expect(ok, d)
  t:expect(ok and d.format == "diva" and d.main == 40 and d.lrig == 11)
  ok, d = t:deck_file(1, "WDK09_blue_umr")
  t:expect(ok, d)
  t:expect(ok and d.format == "key" and d.main == 40 and d.lrig == 10)
end)

case("deck: DB 카드 값이 그대로 들어온다", "WXDi-D01-013 카드 데이터", function(t)
  t:start{db = true}
  local c = t:put(t:no("WXDi-D01-013"), 0, "hand")  -- 翠将　センノリキュウ: 緑 Lv2 10000 LB
  t:expect(t:power(c) == 10000 and t:level(c) == 2 and t:color(c) == COLOR_GREEN)
end)

case("deck: 두 테스트 덱으로 게임 시작 절차가 끝난다", "faq.txt 「ゲーム開始時」", function(t)
  t:start{db = true, seed = 3, first = 0}
  t:expect(t:deck_file(0, "WXDi-D01_ancient_surprise"))
  t:expect(t:deck_file(1, "WDK09_blue_umr"))
  t:start_game()
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 7 and t:count(1, "life_cloth") == 7)
  t:expect(t:center(0) ~= nil and t:center(1) ~= nil)
end)
