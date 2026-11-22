-- 키 셀렉션(포맷 FAQ: キーセレクション)
-- ＜鍵アイコン＞·＜ディーヴァアイコン＞ 카드와 그 같은 이름의 이전 카드. 레벨 0 루리그는 제한 없이 쓸 수 있다.
local function allowed(c)
  if c.lrig and c.level == 0 then return true end
  return Common.has_icon(c, Deck.FORMAT_KEY | Deck.FORMAT_DIVA)
end

function check(deck)
  local p = Common.check(deck)
  Common.check_pool(p, deck, "키 셀렉션", allowed)
  return p
end
