-- WX04 부스터 카드 스크립트 케이스와 새 메커니즘(코스트 없이 사용, 시그니 1체 제한 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, RS, US, GS, KS, OPP, MID, BIG, LV2 = 200000, 200001, 200002, 200003, 200004, 101000, 101500, 102000, 101200
local BIK, ATOM, MAZE, AKU, SPELL = 200010, 200011, 200012, 200013, 200014

-- lrig·p1: 이 부스터의 번호(숫자)나 카드 번호 문자열. N은 여기서 채운다
local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 105 do N[i] = t:no(("WX04-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] end
  lrig, p1 = pick_card(lrig or 1), p1 and pick_card(p1)
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(US, 1000, COLOR_BLUE, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(KS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(LV2, 2000, COLOR_GREEN, 2)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = BIK, power = 2000, level = 1, classes = {"精像：美巧"}, color = COLOR_GREEN}
  t:card{cid = ATOM, power = 2000, level = 1, classes = {"精羅：原子"}, color = COLOR_BLUE}
  t:card{cid = MAZE, power = 2000, level = 1, classes = {"精械：迷宮"}, color = COLOR_WHITE}
  t:card{cid = AKU, power = 2000, level = 2, classes = {"精像：悪魔"}, color = COLOR_BLACK}
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_GREEN}
  t:script(SPELL, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or t:no("WX01-001"), 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WS, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:request().min == n, "코스트 " .. n .. " / " .. t:request().min)
  t:expect(t:answer(table.unpack(t:request().options, 1, n)))
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function zone(t)
  t:expect(t:wait(HINT_ZONE), "존")
  t:expect(t:answer(t:request().options[1]))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end

-- ── 코스트 없이 사용 ──

case("ミルルン・ヨクト: 상대 패의 스펠을 코스트 없이 쓴다. 쓰면 상대 트래시, 안 쓰면 패에 남는다", "WX04-003 FAQ 1·2", function(t)
  for _, yes in ipairs{true, false} do
    wd(t, "WX04-012")
    local g, sp = t:put(N[3], 0, "lrig_deck"), t:put(SPELL, 1, "hand")
    t:put(OPP, 1, "hand")
    ena(t, 3, US)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    t:expect(t:wait(HINT_PAY_ENA))
    t:expect(t:answer(table.unpack(t:request().options, 1, 3)))
    t:expect(t:wait(HINT_SELECT))
    if yes then t:expect(t:answer(sp)) else t:expect(t:answer()) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(sp, 1, yes and "trash" or "hand") and t:count(0, "hand") == (yes and 2 or 0) and t:count(0, "ena") == 0)
  end
end)

case("マインド・マインズ: 상대 덱에서 스펠이 나올 때까지. 쓰지 않으면 상대 트래시", "WX04-015 FAQ 2·4", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t, "WX04-012")
    local a = t:put(N[15], 0, "lrig_deck")
    local sp = t:put(SPELL, 1, "main_deck")
    t:put(OPP, 1, "main_deck")
    ena(t, 1, US)
    main(t)
    use(t, a)
    pay(t, 1)
    pick(t, HINT_SCRIPT, yes)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(sp, 1, "trash") and t:count(0, "hand") == 2 * yes and t:count(1, "main_deck") == 16)
  end
end)

case("コードピルルク・E: 루리그 덱의 청 아츠(메인·코스트 3 이하)를 코스트 없이", "WX04-011", function(t)
  wd(t, "WX01-017")
  t:card{cid = 300000, type = TYPE_ARTS, color = COLOR_BLUE, timing = TIMING_MAIN, cost = "{U}{C}{C}"}
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  local g, a = t:put(N[11], 0, "lrig_deck"), t:put(t:no("WX01-018"), 0, "lrig_deck")
  local b = t:put(300000, 0, "lrig_deck")
  ena(t, 2, US)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 1)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1, "アンチ・スペル는 메인이 아니다")
  t:expect(t:answer(b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:is_in(b, 0, "lrig_trash") and t:is_in(a, 0, "lrig_deck") and t:count(0, "ena") == 0)
end)

case("ファフニール: 다음 스펠 《白》2 감소, 상대가 打ち消せない", "WX04-008 FAQ 1", function(t)
  wd(t, 1, "WX01-016")
  local a, sp, sp2 = t:put(N[8], 0, "lrig_deck"), t:put(t:no("WX01-063"), 0, "hand"), t:put(t:no("WX01-062"), 0, "hand")
  local anti = t:put(t:no("WX01-018"), 1, "lrig_deck")
  for _ = 1, 2 do t:put(US, 1, "ena") end
  ena(t, 1)
  main(t)
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  use(t, sp)
  t:expect(t:wait(HINT_CUTIN))
  use(t, anti)
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(sp, 0, "trash") and not t:saw(HINT_PAY_ENA), "코스트 0, 打ち消されない")
  use(t, sp2)
  t:expect(t:wait(HINT_PAY_ENA), "다음 스펠은 줄지 않는다")
end)

-- ── アルテマ/メイデン ──

case("アルテマ/メイデン: 라이프 1장 이하에서 그로우. 시그니는 1체만, 넘으면 턴 플레이어부터 골라 트래시", "WX04-005 FAQ 1", function(t)
  wd(t, "WD07-001")
  local g = t:put(N[5], 0, "lrig_deck")
  local a, b = t:put(KS, 0, "signi_left"), t:put(KS, 0, "signi_center")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  local h = t:put(KS, 0, "hand")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_MAIN) and t:is_in(g, 0, "lrig_deck"), "라이프 5장이면 못 한다")
  wd(t, "WD07-001")
  g = t:put(N[5], 0, "lrig_deck")
  a, b = t:put(KS, 0, "signi_left"), t:put(KS, 0, "signi_center")
  x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  h = t:put(KS, 0, "hand")
  for i, c in ipairs(t:cards(0, "life_cloth")) do if i > 1 then t:move(c, 0, "exclude") end end
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  t:expect(t:wait(HINT_RULE_TRASH))
  t:expect(t:request().player == 0 and t:answer(b))
  t:expect(t:wait(HINT_RULE_TRASH))
  t:expect(t:request().player == 1 and t:answer(y))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 0, "trash") and t:is_in(y, 1, "trash") and t:action(ACT_PLAY, h, "signi_right") == nil)
end)

case("アルテマ/メイデン: 드로 페이즈에 1장, 그로우 페이즈는 건너뛴다", "WX04-005", function(t)
  wd(t, 5)
  local g = t:put(t:no("WX04-022"), 0, "lrig_deck")
  t:begin(0, PHASE_UP)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and not t:saw(HINT_GROW))
end)

-- ── 그 밖의 새 메커니즘 ──

case("バイオレンス・スプラッシュ: 파워 0 바니시는 트래시로, 내 시그니 효과의 마이너스는 2배(겹친다)", "WX04-038 FAQ 1", function(t)
  wd(t, "WD07-001")  -- イオナ 한정
  local sp, d, x, y = t:put(N[38], 0, "hand"), t:put(N[53], 0, "signi_left"), t:put(MID, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  ena(t, 4, KS)
  main(t)
  use(t, sp)
  t:step()
  if t:request().hint == HINT_PAY_ENA then t:answer(table.unpack(t:request().options, 1, t:request().min)) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_ABILITY, d)))
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash"), "9000 − 10000 → 트래시")
end)

case("コードアート A・C・G: 상대는 메인 페이즈에 자기 시그니를 트래시에 둘 수 없다", "WX04-046", function(t)
  wd(t, 1)
  t:put(N[46], 1, "signi_left")
  t:put(WS, 0, "signi_left")
  main(t)
  t:expect(t:action(ACT_REMOVE) == nil)
end)

case("タワブ: 다른 시그니와 자리를 바꾼다(같은 객체)", "WX04-061", function(t)
  wd(t, "WX04-022")
  local h, a = t:put(N[61], 0, "hand"), t:put(KS, 0, "signi_right")
  t:single(a, EFFECT_UPDATE_POWER, 3000, 0)
  main(t)
  play(t, h)
  pick(t, HINT_TARGET, a)
  pick(t, HINT_SCRIPT, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "signi_right") and t:is_in(a, 0, "signi_left") and t:power(a) == 4000)
end)

case("ゲット・ゲート: 낸 에나 색마다 1장(같은 색 셋이면 1장)", "WX04-063 FAQ 1", function(t)
  wd(t, 1)
  local sp = t:put(N[63], 0, "hand")
  local a, b, c = t:put(WS, 0, "main_deck"), t:put(RS, 0, "main_deck"), t:put(WS, 0, "main_deck")
  ena(t, 1)
  ena(t, 2, RS)
  main(t)
  use(t, sp)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(a, c), "백 2장은 안 된다")
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "hand") and t:is_in(b, 0, "hand"))
end)

case("ツヴァイ＝サリナ: 상대 턴에 레벨 2 이하와 배틀하면 배틀 뒤 그것을 바니시(자신이 바니시되어도)", "WX04-099", function(t)
  wd(t, "WX02-004")
  local s = t:put(N[99], 0, "signi_center")
  local x = t:put(LV2, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(s, 0, "ena") and t:is_in(x, 1, "ena"))
end)

case("アン＝フォース: 정면이 빈 어택을 《緑》《無》와 ＜美巧＞로 무효", "WX04-004 FAQ 3", function(t)
  wd(t, 4)
  local h, x = t:put(BIK, 0, "hand"), t:put(BIG, 1, "signi_left")
  t:single(x, EFFECT_DOUBLE_CRUSH, 1, 1)
  ena(t, 2, GS)
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 2)
  pick(t, HINT_DISCARD, h)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:count(0, "life_cloth") == 5)
end)

case("辛苦の閻魔 ウリス: 【チャーム】 3장으로 바니시(턴 제한 없음)", "WX04-021 FAQ 1", function(t)
  local lc = wd(t, 21)
  local x = t:put(BIG, 1, "signi_left")
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do
    local h = t:put(AKU, 0, z)
    t:attach(t:put(KS, 0, "hand"), h, "charm")
  end
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc, 2)))
  t:step()
  if t:request().hint == HINT_SELECT then t:answer(table.unpack(t:request().options, 1, 3)) end
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena"))
end)

case("コンテンポラ: ＜美巧＞는 상대 시그니·루리그 효과를 받지 않는다. 상대 효과로 트래시되면 《緑》으로 패에", "WX04-035 FAQ 1", function(t)
  wd(t, "WX04-017")
  local c, b = t:put(N[35], 0, "signi_left"), t:put(BIK, 0, "signi_center")
  local h = t:put(N[35], 0, "hand")
  ena(t, 1, GS)
  local d = t:put(t:no("WX03-004"), 1, "lrig_deck")
  for _ = 1, 4 do t:put(US, 1, "ena") end
  t:put(t:no("WX02-072"), 1, "signi_left")
  main(t, 1)
  use(t, d)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)))
  t:step()
  if t:request().hint == HINT_SELECT then t:answer(h) end
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  t:wait(HINT_MAIN)
  t:expect(t:is_in(h, 0, "hand"), "패에서 버려져도(FAQ 1)")
end)

case("シエンコ: 처리할 때 파워만큼 더한다(두 번이면 4배)", "WX04-049 FAQ 1·2", function(t)
  wd(t, "WX01-019")
  local h = t:put(N[49], 0, "signi_left")
  ena(t, 4, GS)
  main(t)
  for k = 1, 2 do
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    pay(t, 2)
    t:expect(t:wait(HINT_MAIN))
  end
  t:expect(t:power(h) == 36000, "＋1000까지 친 9000을 두 번 2배: " .. t:power(h))
end)

case("ダーク・マター: 턴 플레이어부터 고르고 함께 트래시. 내 시그니가 없으면 라이프 1장", "WX04-025 FAQ 3", function(t)
  wd(t, "WX04-022")
  local a, m, x = t:put(N[25], 0, "lrig_deck"), t:put(KS, 0, "signi_left"), t:put(BIG, 1, "signi_left")
  ena(t, 3, KS)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  use(t, a)
  pay(t, 3)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().player == 0 and t:answer(m))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().player == 1 and t:answer(x))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(m, 0, "trash") and t:is_in(x, 1, "trash") and t:count(0, "life_cloth") == 6)
end)
