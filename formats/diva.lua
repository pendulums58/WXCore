-- 디바 셀렉션(포맷 FAQ: ディーヴァセレクション)
-- ＜ディーヴァアイコン＞ 카드와 그 같은 이름의 이전 카드. 레벨 0 루리그는 이름이 달라도
-- ＜ディーヴァアイコン＞으로 재록된 루리그와 색·루리그 타입이 같으면 쓸 수 있다.
local function allowed(c)
  if Common.has_icon(c, Deck.FORMAT_DIVA) then return true end
  if c.lrig and c.level == 0 then
    for _, t in ipairs(c.lrig_types) do
      if Deck.HasFormatLrig0(c.color, t, Deck.FORMAT_DIVA) then return true end
    end
  end
  return false
end

function check(deck)
  local p = Common.check(deck)
  Common.check_pool(p, deck, "디바 셀렉션", allowed)
  -- 같은 루리그 타입의 다른 색 루리그를 한 덱에 넣을 수 없다(설계: 포맷과 덱 검증, 디바 규칙)
  local colors, labels = {}, {}
  for _, c in ipairs(deck.lrig) do
    if c.lrig or c.assist then
      for _, t in ipairs(c.lrig_types) do
        colors[t] = colors[t] or {}
        colors[t][c.color] = true
        labels[t] = labels[t] or {}
        labels[t][#labels[t] + 1] = c.label
      end
    end
  end
  for t, set in pairs(colors) do
    local n = 0
    for _ in pairs(set) do n = n + 1 end
    if n > 1 then p[#p + 1] = string.format("디바 셀렉션: 루리그 타입 <%s>에 색이 다른 루리그가 섞였다", Deck.LrigTypeName(t)) end
  end
  return p
end
