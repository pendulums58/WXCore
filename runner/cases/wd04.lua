-- WD04 緑姫 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 초록 시그니(덱 채우기·에나), 101: 상대 시그니(파워 3000), 102: 상대 시그니(파워 12000), 103: 내 시그니(파워 15000)
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD04-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精生：地獣"}, color = COLOR_GREEN}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 12000, level = 3, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 103, power = 15000, level = 1, classes = {"精生：地獣"}, color = COLOR_GREEN}
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
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
end

local function play(t, card, zone)
  t:expect(t:answer(t:action(ACT_PLAY, card, zone or "signi_left")))
end

local function attack(t, signi)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(signi))
end

local function contains(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

-- ── 001 四ノ娘　緑姫 ──

case("D04-001: セイリュ가 있고 에나 7장 이상이면 내 시그니 ＋2000. 2체여도 한 번", "WD04-001 FAQ 1", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  local sr = t:put(N["009"], 0, "signi_center")
  ena(t, 6)
  t:expect(t:power(s) == 1000, "에나 6장이면 없다")
  t:put(100, 0, "ena")
  t:expect(t:power(s) == 3000 and t:power(sr) == 14000, "에나 7장")
  t:put(N["009"], 0, "signi_right")
  t:expect(t:power(s) == 3000, "セイリュ 2체여도 ＋2000")
  wd(t, "001")
  s = t:put(100, 0, "signi_left")
  ena(t, 7)
  t:expect(t:power(s) == 1000, "セイリュ가 없으면 없다")
end)

-- ── 006 意気揚々 ──

case("D04-006: 쓸 때 장에 있는 시그니만 ＋5000. 뒤에 나온 시그니는 오르지 않는다. 【マルチエナ】로 낼 수 있다", "WD04-006 FAQ 1", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local a = t:put(100, 0, "signi_left")
  local b = t:put(101, 0, "signi_center")
  local later = t:put(100, 0, "hand")
  local q2 = t:put(N["016"], 0, "ena")
  use(t, arts, {q2})
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 6000 and t:power(b) == 8000)
  play(t, later, "signi_right")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(later) == 1000, "뒤에 나온 시그니")
end)

-- ── 007 再三再四 ──

case("D04-007: 코스트를 낸 뒤 에나에서 2장까지 대상으로 패에. 코스트로 낸 카드는 고를 수 없다", "WD04-007 FAQ 1", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  local e = ena(t, 3)
  use(t, arts, {e[1]})
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 2 and not contains(o, e[1]) and t:request().min == 0, "코스트로 낸 카드는 트래시에 있다")
  t:expect(t:answer(e[2], e[3]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(e[2], 0, "hand") and t:is_in(e[3], 0, "hand") and t:is_in(e[1], 0, "trash"))
end)

-- ── 008 付和雷同 ──

case("D04-008: 상대의 파워 12000 이상 시그니만 대상으로 바니시", "WD04-008", function(t)
  wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  local small = t:put(101, 1, "signi_left")
  local big = t:put(102, 1, "signi_center")
  use(t, arts, ena(t, 3))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == big)
  t:expect(t:answer(big))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(big, 1, "ena") and t:is_in(small, 1, "signi_left"))
end)

-- ── 009 幻獣　セイリュ ──

case("D04-009: 내 시그니 3체가 모두 15000 이상인 동안 【ランサー】와 어택 시 바니시를 얻는다", "WD04-009", function(t)
  -- 부여(EFFECT_GRANT)는 엔진이 처리할 때 맞춘다. 장을 바꿀 때마다 메인 페이즈를 다시 연다
  local function setup(n, third_power)
    wd(t, "001")
    local sr = t:put(N["009"], 0, "signi_left")
    t:single(sr, EFFECT_UPDATE_POWER, 3000, 0)
    if n >= 2 then t:put(103, 0, "signi_center") end
    if n >= 3 then
      local x = t:put(100, 0, "signi_right")
      t:single(x, EFFECT_UPDATE_POWER, third_power - 1000, 0)
    end
    main(t)
    return sr
  end
  t:expect(not t:keyword(setup(2), EFFECT_LANCER), "2체뿐")
  t:expect(not t:keyword(setup(3, 14000), EFFECT_LANCER), "3체째가 15000 미만")
  t:expect(t:keyword(setup(3, 15000), EFFECT_LANCER), "셋 다 15000 이상")
end)

case("D04-009: 얻은 【自】는 어택 선언과 함께 바니시하고, 그 뒤 정면과 배틀한다", "WD04-009 FAQ 1·2", function(t)
  wd(t, "001")
  local sr = t:put(N["009"], 0, "signi_left")
  t:single(sr, EFFECT_UPDATE_POWER, 3000, 0)
  t:put(103, 0, "signi_center")
  t:put(103, 0, "signi_right")
  local front = t:put(101, 1, "signi_right")  -- signi_left의 정면
  local other = t:put(101, 1, "signi_center")
  attack(t, sr)
  t:expect(t:wait(HINT_TARGET))
  t:expect(contains(t:request().options, front), "배틀보다 먼저라 정면도 아직 장에 있다")
  t:expect(t:answer(other))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(other, 1, "ena") and t:is_in(front, 1, "ena"), "능력으로 1체, 배틀로 정면")
  t:expect(t:count(1, "life_cloth") == 4, "【ランサー】")
end)

case("D04-009: 라이프 버스트 — 상대의 파워 10000 이상 시그니 1체 바니시", "WD04-009", function(t)
  wd(t, "001")
  t:put(N["009"], 0, "life_cloth")
  t:card{cid = 111, power = 10000, level = 1}
  local att = t:put(111, 1, "signi_right")
  t:put(101, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == att)
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(att, 1, "ena"))
end)

-- ── 010 幻獣　ミスザク / 011 幻獣　ビグタット ──

case("D04-010·011: ビグタット 【出】로 장의 시그니 전부 ＋2000(자신 포함, 뒤에 나온 건 아님). ミスザク는 10000 이상이 되면 【ランサー】", "WD04-010, WD04-011 FAQ 5", function(t)
  wd(t, "001")
  local mz = t:put(N["010"], 0, "signi_left")
  local bg = t:put(N["011"], 0, "hand")
  local later = t:put(100, 0, "hand")
  t:expect(t:power(mz) == 8000 and not t:keyword(mz, EFFECT_LANCER))
  main(t)
  play(t, bg, "signi_center")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(mz) == 10000 and t:power(bg) == 10000)
  t:expect(t:keyword(mz, EFFECT_LANCER), "10000 이상")
  play(t, later, "signi_right")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(later) == 1000)
end)

-- ── 012 幻獣　コアラン ──

case("D04-012: 【出】 내 시그니 1체 ＋3000. 자기 자신도 고를 수 있다", "WD04-012 FAQ 5", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  local ka = t:put(N["012"], 0, "hand")
  t:put(101, 1, "signi_left")
  main(t)
  play(t, ka, "signi_center")
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 2 and contains(o, s) and contains(o, ka), "내 시그니만, 자신 포함")
  t:expect(t:answer(ka))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(ka) == 8000 and t:power(s) == 1000)
end)

-- ── 013 幻獣　コゲンブ / 015 幻獣　ヒャッコ ──

case("D04-013·015: 어택했을 때 파워가 기준 이상이면 덱 위 1장을 에나에. 정면이 더 커도 어택·발동한다", "WD04-013 FAQ 1, WD04-015 FAQ 1", function(t)
  wd(t, "001")
  local kg = t:put(N["013"], 0, "signi_left")
  attack(t, kg)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "ena") == 0, "コゲンブ 3000이면 없다")
  wd(t, "001")
  kg = t:put(N["013"], 0, "signi_left")
  t:single(kg, EFFECT_UPDATE_POWER, 2000, 0)
  local fr = t:put(102, 1, "signi_right")  -- 정면 12000
  attack(t, kg)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "main_deck") == 9 and t:count(0, "ena") == 1, "5000이면 덱 위를 에나에")
  t:expect(t:is_in(fr, 1, "signi_right"), "정면이 더 크면 배틀로 바니시되지 않는다")
  wd(t, "001")
  local hy = t:put(N["015"], 0, "signi_left")
  attack(t, hy)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "ena") == 0, "ヒャッコ 1000이면 없다")
  wd(t, "001")
  hy = t:put(N["015"], 0, "signi_left")
  t:single(hy, EFFECT_UPDATE_POWER, 2000, 0)
  attack(t, hy)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "ena") == 1, "3000이면 에나에")
end)

-- ── 018 堕絡 ──

case("D04-018: 내 업 시그니와 그 파워 이하의 상대 시그니를 같이 대상으로. 다운하고 바니시", "WD04-018 FAQ 2·4·5", function(t)
  wd(t, "001")
  local sp = t:put(N["018"], 0, "hand")
  local up = t:put(103, 0, "signi_left")
  local down = t:put(103, 0, "signi_center")
  t:set_flags(down, CF_DOWN)
  local small = t:put(101, 1, "signi_left")
  t:card{cid = 112, power = 20000, level = 1}
  local huge = t:put(112, 1, "signi_center")
  use(t, sp, ena(t, 1))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == up, "다운 상태는 못 고른다(FAQ 4)")
  t:expect(t:answer(up))
  t:expect(t:wait(HINT_TARGET))
  o = t:request().options
  t:expect(#o == 1 and o[1] == small, "파워가 더 큰 시그니는 못 고른다(FAQ 5)")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(up) & CF_DOWN ~= 0 and t:is_in(small, 1, "ena") and t:is_in(huge, 1, "signi_center"))
end)
