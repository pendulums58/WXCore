-- 모든 포맷에 공통인 덱 구성 검사. 포맷 스크립트가 Common.check(deck)를 부르고 카드 범위 검사를 더한다.
-- deck = { format, main = {카드...}, lrig = {카드...}, start = { center = 카드, assist = {카드...} } }
-- 카드 = { cid, name_key(같은 이름 판정: alias, 없으면 cid), label(표시 이름), level, color, formats, life_burst,
--          lrig, assist, arts, piece, key, resona, signi, spell, lrig_types(루리그 타입 ID) }
Common = {}

local function add(p, fmt, ...)
  p[#p + 1] = string.format(fmt, ...)
end

-- 같은 이름(name_key)마다 장 수. 일본어 이름이 없는 오리카도 cid로 센다
local function count_names(cards)
  local n, label, order = {}, {}, {}
  for _, c in ipairs(cards) do
    local k = c.name_key or c.cid
    if not n[k] then
      n[k] = 0
      label[k] = c.label or c.cid
      order[#order + 1] = k
    end
    n[k] = n[k] + 1
  end
  return n, label, order
end

local function in_list(list, card)
  for _, c in ipairs(list) do
    if c.cid == card.cid then return true end
  end
  return false
end

function Common.check(deck)
  local p = {}

  -- 메인 덱: 시그니·스펠, 40장 정확히, 라이프 버스트 20장 이하, 같은 이름 4장까지(용어집: メインデッキ)
  for _, c in ipairs(deck.main) do
    if not (c.signi or c.spell) then add(p, "메인 덱에 넣을 수 없는 카드: %s", c.label or c.cid) end
  end
  if #deck.main ~= 40 then add(p, "메인 덱은 40장이어야 한다(지금 %d장)", #deck.main) end
  local lb = 0
  for _, c in ipairs(deck.main) do
    if c.life_burst then lb = lb + 1 end
  end
  if lb > 20 then add(p, "라이프 버스트 카드는 20장까지(지금 %d장)", lb) end
  local n, label, order = count_names(deck.main)
  for _, name in ipairs(order) do
    if n[name] > 4 then add(p, "같은 이름은 4장까지: %s %d장", label[name], n[name]) end
  end

  -- 루리그 덱: 같은 이름 불가(용어집: デッキ), 최대 10장.
  -- 레벨 0 루리그가 3장 이상이면 피스를 2장까지 더 넣을 수 있어 최대 12장(용어집: ルリグデッキ, ピース)
  for _, c in ipairs(deck.lrig) do
    if not (c.lrig or c.assist or c.arts or c.resona or c.key or c.piece) then add(p, "루리그 덱에 넣을 수 없는 카드: %s", c.label or c.cid) end
  end
  n, label, order = count_names(deck.lrig)
  for _, name in ipairs(order) do
    if n[name] > 1 then add(p, "루리그 덱에는 같은 이름을 넣을 수 없다: %s %d장", label[name], n[name]) end
  end
  local lrig0, pieces, team = 0, 0, 0
  for _, c in ipairs(deck.lrig) do
    if (c.lrig or c.assist) and c.level == 0 then lrig0 = lrig0 + 1 end
    if c.piece then pieces = pieces + 1 end
    if c.team_icon then team = team + 1 end
  end
  if #deck.lrig - pieces > 10 then add(p, "루리그 덱은 피스를 빼고 10장까지(지금 %d장)", #deck.lrig - pieces) end
  -- 피스는 「追加で」 넣는 것이라 레벨 0 루리그가 3장 이상일 때만(faq.txt 「ピース」)
  if pieces > 0 and lrig0 < 3 then add(p, "피스는 레벨 0 루리그가 3장 이상일 때만 넣을 수 있다") end
  if pieces > 2 then add(p, "피스는 2장까지(지금 %d장)", pieces) end
  -- 【チーム】·【ドリームチーム】 아이콘을 가진 피스끼리는 같이 넣을 수 없다(용어집: チームアイコン, ドリームチームアイコン)
  if team > 1 then add(p, "【チーム】·【ドリームチーム】 피스는 1장까지(지금 %d장)", team) end

  -- 시작 루리그: 레벨 0 센터 루리그 1장, 어시스트를 쓰면 레벨 0 루리그 2장을 더해 3장(설계: 포맷과 덱 검증).
  -- 디바의 어시스트는 카드 종류가 아니라 자리라 보통 루리그 카드가 온다(WXDi-D01: 타윌=놀·움르=놀)
  local s = deck.start or {}
  if not s.center then
    add(p, "시작 센터 루리그를 정해야 한다(레벨 0 루리그를 눌러 지정)")
  elseif not (s.center.lrig and s.center.level == 0) then
    add(p, "시작 센터 루리그는 레벨 0 루리그여야 한다: %s", s.center.label or s.center.cid)
  elseif not in_list(deck.lrig, s.center) then
    add(p, "시작 센터 루리그가 루리그 덱에 없다: %s", s.center.label or s.center.cid)
  end
  local assists = s.assist or {}
  if #assists ~= 0 and #assists ~= 2 then add(p, "시작 루리그는 1장 또는 3장(어시스트 %d장)", #assists) end
  local used = {}
  if s.center then used[s.center.cid] = true end
  for _, c in ipairs(assists) do
    if used[c.cid] then add(p, "같은 카드를 시작 루리그로 두 번 지정했다: %s", c.label or c.cid) end
    used[c.cid] = true
    if not ((c.lrig or c.assist) and c.level == 0) then
      add(p, "시작 어시스트 루리그는 레벨 0 루리그여야 한다: %s", c.label or c.cid)
    elseif not in_list(deck.lrig, c) then
      add(p, "시작 어시스트 루리그가 루리그 덱에 없다: %s", c.label or c.cid)
    end
  end
  return p
end

-- 카드 범위 검사: allowed(card)가 거짓인 카드를 같은 이름마다 한 번씩 알린다
function Common.check_pool(p, deck, format_label, allowed)
  local seen = {}
  for _, list in ipairs({ deck.lrig, deck.main }) do
    for _, c in ipairs(list) do
      local k = c.name_key or c.cid
      if not seen[k] and not allowed(c) then
        seen[k] = true
        add(p, "%s에서 쓸 수 없는 카드: %s", format_label, c.label)
      end
    end
  end
end

-- 포맷 아이콘이 붙었거나, 아이콘이 붙은 같은 이름 카드가 있는가(포맷 FAQ: 「同名のカードであれば、以前のカードも使用できます」)
function Common.has_icon(c, bits)
  return (c.formats & bits) ~= 0 or Deck.NameHasFormat(c.name_key or c.cid, bits)
end
