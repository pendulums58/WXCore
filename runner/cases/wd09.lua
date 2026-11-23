-- WD09 サシェ 구축덱 카드 스크립트 케이스 + 레조나 룰. 근거는 카드별 FAQ(cards.json)·용어집

local N = {}

-- 200: 백 ＜宇宙＞ 레벨 1, 201: 백 ＜宇宙＞ 레벨 0, 202: 백 ＜宇宙＞ 레벨 2, 203: 백 ＜英知＞ 레벨 2(우주 아님)
-- 101: 상대 시그니 레벨 1, 102: 상대 시그니 레벨 3
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD09-" .. no)
  end
  t:card{cid = 200, power = 1000, level = 1, classes = {"精羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 201, power = 1000, level = 0, classes = {"精羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 202, power = 5000, level = 2, classes = {"精羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 203, power = 5000, level = 2, classes = {"精像：英知"}, color = COLOR_WHITE}
  t:card{cid = 101, power = 3000, level = 1, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:card{cid = 102, power = 10000, level = 3, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:fill(200, 0, "main_deck", 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "001"], 0, "lrig_center")
  t:put(N["001"], 1, "lrig_center")  -- 상대도 레벨 4(레조나를 둘 수 있게)
  return center
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(200, 0, "ena") end
  return t:cards(0, "ena")
end

local function has(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

-- ── 레조나 룰 ──

case("레조나: 출현 조건 카드를 트래시에 두고 시그니 존에. 【出】은 강제", "용어집: 出現条件, WD09-008 FAQ 3", function(t)
  wd(t, "001")
  local venus = t:put(N["008"], 0, "lrig_deck")
  local a = t:put(200, 0, "signi_left")
  local b = t:put(200, 0, "signi_center")
  local small = t:put(101, 1, "signi_center")
  local big = t:put(102, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, venus)))
  t:expect(t:wait(HINT_RESONA))
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(not has(t:request().options, big), "레벨 3은 대상이 아니다")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "trash") and t:is_in(b, 0, "trash"), "출현 조건으로 트래시")
  t:expect(not t:is_in(venus, 0, "lrig_deck") and t:count(0, "signi_left") + t:count(0, "signi_center") >= 1)
  t:expect(t:is_in(small, 1, "hand"))
  t:expect(t:count(0, "ena") == 1, "サシェ・プレンヌ: 레조나가 나오면 에나 1장(WD09-001)")
end)

case("레조나: 출현 조건이 모자라면 낼 수 없다. 레조나·다른 클래스는 세지 않는다", "WD09-007 출현 조건", function(t)
  wd(t, "001")
  local merc = t:put(N["007"], 0, "lrig_deck")
  local venus = t:put(N["008"], 0, "lrig_deck")
  t:put(200, 0, "signi_left")
  t:put(203, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_RESONA, venus) == nil, "＜宇宙＞ 1체뿐")
  t:expect(t:action(ACT_RESONA, merc) == nil)
end)

case("레조나: 출현 조건 선택을 취소하면 아무것도 바뀌지 않는다", "설계: 확정 전 취소, WD09-007 FAQ 2", function(t)
  wd(t, "001")
  local venus = t:put(N["008"], 0, "lrig_deck")
  local a = t:put(200, 0, "signi_left")
  local b = t:put(200, 0, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, venus)))
  t:expect(t:wait(HINT_RESONA))
  t:expect(t:cancel())
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(venus, 0, "lrig_deck") and t:is_in(a, 0, "signi_left") and t:is_in(b, 0, "signi_center"))
end)

case("레조나: 낸 뒤 레벨 합계가 리미트 이하. 출현 조건으로 떠나는 시그니는 빼고 센다", "사용자 결정 2026-11-24, faq.txt 「メインフェイズ」 2", function(t)
  local center = wd(t, "001")
  t:single(center, EFFECT_UPDATE_LIMIT, -8, 0)  -- 리미트 3
  local venus = t:put(N["008"], 0, "lrig_deck")
  local a = t:put(201, 0, "signi_left")    -- 레벨 0
  local b = t:put(200, 0, "signi_center")  -- 레벨 1
  local c = t:put(202, 0, "signi_right")   -- 레벨 2
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, venus)))
  t:expect(t:wait(HINT_RESONA))
  t:expect(not t:answer(a, b), "남는 2 + 레조나 2 = 4 > 3")
  t:expect(t:answer(a, c), "남는 1 + 레조나 2 = 3")
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:is_in(b, 0, "signi_center"))
end)

case("레조나: 어떻게 골라도 리미트를 넘으면 행동이 없다", "사용자 결정 2026-11-24", function(t)
  local center = wd(t, "001")
  t:single(center, EFFECT_UPDATE_LIMIT, -9, 0)  -- 리미트 2
  local venus = t:put(N["008"], 0, "lrig_deck")
  t:put(201, 0, "signi_left")
  t:put(201, 0, "signi_center")
  local other = t:put(203, 0, "signi_right")  -- 레벨 2, ＜宇宙＞ 아님
  main(t)
  t:expect(t:action(ACT_RESONA, venus) == nil, "남는 2 + 레조나 2 = 4 > 2")
  center = wd(t, "001")
  t:single(center, EFFECT_UPDATE_LIMIT, -9, 0)
  venus = t:put(N["008"], 0, "lrig_deck")
  t:put(201, 0, "signi_left")
  t:put(201, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_RESONA, venus) ~= nil, "남는 0 + 레조나 2 = 2")
end)

case("레조나: 루리그 레벨보다 높으면 낼 수 없다", "faq.txt 「メインフェイズ」 2", function(t)
  wd(t, "004")  -- サシェ・クロワス 레벨 1
  local venus = t:put(N["008"], 0, "lrig_deck")
  t:put(200, 0, "signi_left")
  t:put(200, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_RESONA, venus) == nil)
end)

case("레조나: 트래시에 놓이는 대신 루리그 덱으로. 트래시에는 가지 않는다", "용어집: レゾナ 2, WXK11-013 FAQ 3, WD09-007 FAQ 3", function(t)
  wd(t, "001")
  local merc = t:put(N["007"], 0, "lrig_deck")
  t:put(200, 0, "signi_left")
  t:put(200, 0, "signi_center")
  t:put(200, 0, "signi_right")
  local ov = t:put(N["008"], 1, "signi_center")  -- 상대의 레조나
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, merc)))
  t:expect(t:wait(HINT_RESONA))
  t:expect(t:answer(table.unpack(t:cards(0, "signi_left")), t:cards(0, "signi_center")[1], t:cards(0, "signi_right")[1]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(ov))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(ov, 1, "lrig_deck"), "루리그 덱으로")
  t:expect(not t:is_in(ov, 1, "trash"), "트래시에는 없다")
end)

case("레조나: 패로 되돌리는 대신 루리그 덱으로", "WX08-007 FAQ 1", function(t)
  wd(t, "001")
  local venus = t:put(N["008"], 0, "lrig_deck")
  t:put(200, 0, "signi_left")
  t:put(200, 0, "signi_center")
  local ov = t:put(N["008"], 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, venus)))
  t:expect(t:wait(HINT_RESONA))
  t:expect(t:answer(t:cards(0, "signi_left")[1], t:cards(0, "signi_center")[1]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(ov))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(ov, 1, "lrig_deck") and not t:is_in(ov, 1, "hand"))
end)

-- ── 카드 ──

case("D09-001: 【起】《ダウン》 ＜宇宙＞ 시그니를 찾아 패에", "WD09-001", function(t)
  local center = wd(t, "001")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
  t:expect(t:action(ACT_ABILITY, center) == nil, "다운 상태")
end)

case("D09-006: 어택할 수 없게 되고 패 1장 버림. 패가 없어도 쓸 수 있다", "WD09-006 FAQ 1", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local o = t:put(101, 1, "signi_center")
  t:put(200, 0, "ena")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:keyword(o, EFFECT_CANNOT_ATTACK), "어택할 수 없다")
  t:expect(t:count(0, "hand") == 0)
end)

case("D09-009: 장에 레조나가 있으면 기본 파워 15000", "WD09-009", function(t)
  wd(t, "001")
  local vega = t:put(N["009"], 0, "signi_left")
  t:expect(t:power(vega) == 12000)
  t:put(N["008"], 0, "signi_center")
  t:expect(t:power(vega) == 15000)
end)

case("D09-009: 【出】《白》 레벨 2 이하 백 시그니를 덱에서 장에. 없다고 해도 된다", "WD09-009 FAQ 1", function(t)
  wd(t, "001")
  local vega = t:put(N["009"], 0, "hand")
  ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, vega, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER) or t:wait(HINT_PAY_ENA))
  if t:request().hint == HINT_USE_TRIGGER then t:answer(1); t:wait(HINT_PAY_ENA) end
  t:expect(t:answer(t:cards(0, "ena")[1]))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "signi_center") + t:count(0, "signi_right") == 1)
end)

case("D09-013: 선언한 레벨의 시그니면 패에, 아니면 덱 위에 그대로", "WD09-013 FAQ 1", function(t)
  wd(t, "001")
  local d1 = t:put(N["013"], 0, "hand")
  local d2 = t:put(N["015"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, d1, "signi_left")))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:count(0, "main_deck") == 9, "레벨 1이라 패에")
  t:expect(t:answer(t:action(ACT_PLAY, d2, "signi_center")))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:answer(3))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "main_deck") == 9, "틀리면 덱 위에 남는다")
end)

case("D09-018: 장에 레조나가 있으면 1장 더 찾는다", "WD09-018", function(t)
  wd(t, "001")
  local sp = t:put(N["018"], 0, "hand")
  t:put(N["008"], 0, "signi_center")
  ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")[1]))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_SELECT), "추가로 한 번 더")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2)
end)
