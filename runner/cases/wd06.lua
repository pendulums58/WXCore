-- WD06 エルドラ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 파랑 ＜水獣＞(덱·에나), 101: 상대 시그니(파워 3000), 102: 라이프 버스트 있는 카드, 103: 흰 시그니(레벨 2)
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD06-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精生：水獣"}, color = COLOR_BLUE}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 1000, level = 1, classes = {"精生：水獣"}, color = COLOR_BLUE, burst = 1}
  t:card{cid = 103, power = 2000, level = 2, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:fill(100, 0, "main_deck", 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "001"], 0, "lrig_center")
  t:put(t:no("WXDi-D01-004"), 1, "lrig_center")  -- 상대 센터 Lv3
  return center
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(100, 0, "ena") end
  return t:cards(0, "ena")
end

local function use(t, card, paid)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, card)))
  if paid then
    t:expect(t:wait(HINT_PAY_ENA))
    t:expect(t:answer(table.unpack(paid)))
  end
end

local function play(t, card, zone)
  t:expect(t:answer(t:action(ACT_PLAY, card, zone or "signi_left")))
end

local function top(t, p)
  local l = t:cards(p, "life_cloth")
  return l[#l]
end

-- ── 001 エルドラ＝マークⅣ´ ──

case("D06-001: 라이프 클로스에 카드가 더해지면 상대 시그니를 대상으로 《青》×3을 내고 바니시. 내지 않으면 아무것도", "WD06-001", function(t)
  wd(t, "001")
  local ch = t:put(N["013"], 0, "hand")
  local opp = t:put(101, 1, "signi_left")
  local e = ena(t, 3)
  main(t)
  play(t, ch)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET), "덱 위가 라이프에 더해져 Ⅳ´ 트리거")
  t:expect(t:answer(opp))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(e)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(opp, 1, "ena") and t:count(0, "trash") == 4, "에나 3장 + 코스트 라이프 1장")
  t:expect(t:count(0, "life_cloth") == 5)
end)

case("D06-001: 내 라이프 버스트가 발동하면 1장 뽑는다", "WD06-001", function(t)
  wd(t, "001")
  t:put(N["016"], 0, "life_cloth")  -- サーバント Ｑ: 에나 차지
  local att = t:put(101, 1, "signi_right")
  t:put(101, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "ena") == 2, "뽑기 + 에나 차지 + 버스트 카드")
end)

-- ── 003 エルドラ＝マークⅡ´ ──

case("D06-003: 파랑 시그니만 ＋1000", "WD06-003", function(t)
  wd(t, "003")
  local b = t:put(100, 0, "signi_left")
  local w = t:put(103, 0, "signi_center")
  t:expect(t:power(b) == 2000 and t:power(w) == 2000)
end)

-- ── 006 クロス・クラッシュ・フラッシュ ──

case("D06-006: 상대 라이프 맨 위를 공개해 【ライフバースト】가 없으면 트래시에. 있으면 그대로", "WD06-006", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local x = top(t, 1)
  use(t, arts, ena(t, 2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:count(1, "life_cloth") == 4)
  wd(t, "001")
  arts = t:put(N["006"], 0, "lrig_deck")
  local lb = t:put(102, 1, "life_cloth")
  use(t, arts, ena(t, 2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(lb, 1, "life_cloth") and t:count(1, "life_cloth") == 6)
end)

-- ── 007 サプライズ・ウィズ・ミー ──

case("D06-007: 라이프 위에서 정한 장수를 보고 순서를 바꾼다. 더한 것이 아니라 Ⅳ´는 트리거하지 않는다", "WD06-007 FAQ 1·2", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  local life = t:cards(0, "life_cloth")
  local a, b = life[#life], life[#life - 1]
  t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:answer(2))
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(b, a))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_TARGET), "Ⅳ´ 트리거 없음")
  t:expect(top(t, 0) == b and t:count(0, "life_cloth") == 5)
end)

-- ── 008 バツ・エニー・アザー ──

case("D06-008: 공개한 맨 위가 선언한 레벨의 시그니면 이 턴 크러시되지 않는다. 턴 끝에 맨 위를 트래시(버스트 없음)", "WD06-008 FAQ 1·2·3", function(t)
  wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  local lb = t:put(102, 0, "life_cloth")  -- 레벨 1, 버스트 있음
  local e = ena(t, 3)
  local att = t:put(101, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(e)))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_MAIN), "내 다음 턴")
  t:expect(not t:saw(HINT_LIFEBURST), "크러시도 턴 끝 트래시도 버스트 없음")
  t:expect(t:is_in(lb, 0, "trash") and t:count(0, "life_cloth") == 5, "시그니·루리그 어택으로 줄지 않고, 상대 턴 끝에 맨 위 1장만")
end)

-- ── 009 幻水　シィラ ──

case("D06-009: 【出】《青》 라이프 1장 크러시. 에나 대신 트래시에 놓고 덱 위를 라이프에", "WD06-009, WD06-001 FAQ 1", function(t)
  wd(t, "001")
  local sh = t:put(N["009"], 0, "hand")
  local x = top(t, 0)
  local e = ena(t, 1)
  main(t)
  play(t, sh)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "trash"), "에나 대신 트래시")
  t:expect(t:count(0, "life_cloth") == 5 and t:count(0, "main_deck") == 9, "덱 위가 라이프에")
  t:expect(t:count(0, "ena") == 0)
end)

case("D06-009: 내 라이프가 상대보다 적으면 내 시그니 ＋1000", "WD06-009", function(t)
  wd(t, "004")
  local sh = t:put(N["009"], 0, "signi_left")
  t:expect(t:power(sh) == 12000)
  t:put(101, 1, "life_cloth")
  t:expect(t:power(sh) == 13000)
end)

-- ── 010·012·014 기본 파워 ──

case("D06-010·012·014: 다른 ＜水獣＞가 있으면 기본 파워가 바뀌고, ＋는 그 위에", "WD06-010, WD06-012, WD06-014", function(t)
  wd(t, "003")
  local o = t:put(N["010"], 0, "signi_left")
  t:expect(t:power(o) == 9000, "혼자면 8000 + Ⅱ´")
  local k = t:put(N["014"], 0, "signi_center")
  t:expect(t:power(o) == 13000 and t:power(k) == 6000, "12000·5000 + Ⅱ´")
  local p = t:put(N["012"], 0, "signi_right")
  t:expect(t:power(p) == 9000)
end)

-- ── 011 幻水　リュウグウ ──

case("D06-011: 【起】《ダウン》 라이프 맨 위를 패에, 덱 위를 라이프에. 라이프가 없으면 아무것도", "WD06-011 FAQ 1·2", function(t)
  wd(t, "004")
  local r = t:put(N["011"], 0, "signi_left")
  local x = top(t, 0)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, r)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "hand") and t:count(0, "life_cloth") == 5 and t:count(0, "main_deck") == 9)
  t:expect(t:action(ACT_ABILITY, r) == nil, "다운 상태")
  wd(t, "004")
  r = t:put(N["011"], 0, "signi_left")
  for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "trash") end
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, r)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 0 and t:count(0, "main_deck") == 10, "라이프가 없으면 덱 위도 안 더한다")
end)

-- ── 013 幻水　チョウアン ──

case("D06-013: 코스트로 라이프 1장 트래시(버스트 없음), 덱 위를 라이프에", "WD06-013 FAQ 1", function(t)
  wd(t, "001")
  local lb = t:put(102, 0, "life_cloth")
  local ch = t:put(N["013"], 0, "hand")
  main(t)
  play(t, ch)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(lb, 0, "trash") and not t:saw(HINT_LIFEBURST))
  t:expect(t:count(0, "life_cloth") == 6 and t:count(0, "main_deck") == 9)
end)

-- ── 018 ＰＬＵＳ　ＲＵＳＨ ──

case("D06-018: 상대 라이프 맨 위를 보고 트래시에 놓으면 상대 덱 위를 라이프에. 그 뒤 1장 뽑는다", "WD06-018 FAQ 1·2", function(t)
  wd(t, "004")
  local sp = t:put(N["018"], 0, "hand")
  local x = top(t, 1)
  use(t, sp)
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:can_see(0, x) and not t:can_see(1, x), "쓴 사람만 본다")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:count(1, "life_cloth") == 5 and t:count(1, "main_deck") == 9)
  t:expect(t:count(0, "hand") == 1)
  wd(t, "004")
  sp = t:put(N["018"], 0, "hand")
  for _, c in ipairs(t:cards(1, "life_cloth")) do t:move(c, 1, "trash") end
  use(t, sp)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1, "라이프가 없어도 뽑는다")
end)
