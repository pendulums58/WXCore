-- 디바(루리그 3체): 어시스트 루리그 그로우, 팀, 마르치 에나, 엔나차지

-- 【出】: 카드를 1장 뽑는다
local DRAW_ON_PLAY = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

-- 센터 タマ, 어시스트 2체 ユヅキ / ウリス. 루리그 덱에 어시스트 카드
local function setup(t, center_level)
  t:lrig(1, center_level or 1, 9, {"タマ"})
  t:lrig(2, 0, 0, {"ユヅキ"})
  t:lrig(3, 0, 0, {"ウリス"})
  t:card{cid = 10, type = TYPE_ASSIST_LRIG, level = 1, limit = 0, classes = {"ユヅキ"}, timing = TIMING_MAIN}
  t:script(10, DRAW_ON_PLAY)
  t:card{cid = 11, type = TYPE_ASSIST_LRIG, level = 2, limit = 1, classes = {"ユヅキ"}, grow = "{C}",
         timing = TIMING_MAIN | TIMING_ATTACK}
  t:card{cid = 12, type = TYPE_ASSIST_LRIG, level = 1, classes = {"ウリス"}, timing = TIMING_ATTACK}
  t:signi(100, 1000)
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  local c = t:put(1, 0, "lrig_center")
  local l = t:put(2, 0, "lrig_assist_left")
  local r = t:put(3, 0, "lrig_assist_right")
  return c, l, r
end

case("assist: 메인 페이즈에 어시스트 루리그를 그로우하고 【出】이 발동한다", "용어집: アシストルリグ, faq.txt 「メインフェイズ」 5", function(t)
  local _, left = setup(t, 2)
  local a1 = t:put(10, 0, "lrig_deck")
  local a2 = t:put(11, 0, "lrig_deck")
  t:put(100, 0, "ena")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_GROW, a2) == nil, "레벨은 하나씩")
  local g = t:action(ACT_GROW, a1, "lrig_assist_left")
  t:expect(g ~= nil)
  local hand = t:count(0, "hand")
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a1, 0, "lrig_assist_left"))
  t:expect(#t:under(a1) == 1 and t:under(a1)[1] == left, "이전 루리그는 아래로")
  t:expect(t:count(0, "hand") == hand + 1, "【出】")
  -- 같은 턴에 몇 번이든
  g = t:action(ACT_GROW, a2, "lrig_assist_left")
  t:expect(g ~= nil, "같은 턴 두 번째 그로우")
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_PAY_ENA), "그로우 코스트 {C}")
  t:expect(t:answer(t:cards(0, "ena")[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a2, 0, "lrig_assist_left") and t:count(0, "ena") == 0)
end)

case("assist: 센터 루리그보다 높은 레벨로는 그로우할 수 없다", "용어집: アシストルリグ", function(t)
  setup(t, 1)
  t:put(10, 0, "lrig_assist_left")  -- 어시스트 Lv1(센터와 같음)
  local a2 = t:put(11, 0, "lrig_deck")
  t:put(100, 0, "ena")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_GROW, a2) == nil)
end)

case("assist: 그로우 페이즈에는 그로우하지 않고, 센터 위에 겹칠 수도 없다", "faq.txt 「グロウフェイズ」, 용어집: アシストルリグ", function(t)
  setup(t, 0)
  t:lrig(5, 0, 0, {"ユヅキ"})
  t:lrig(4, 1, 3, {"ユヅキ"})
  t:move(t:center(0), 0, "lrig_trash")
  t:put(5, 0, "lrig_center")  -- 센터도 ユヅキ: 어시스트 카드와 타입이 같다
  local a1 = t:put(10, 0, "lrig_deck")
  local l1 = t:put(4, 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == l1, "후보는 보통 루리그뿐")
  t:expect(t:is_in(a1, 0, "lrig_deck"))
end)

case("assist: 사용 타이밍 【アタックフェイズ】면 양쪽 어택 페이즈에 그로우할 수 있다", "용어집: アシストルリグ, faq.txt 「アタックフェイズ」", function(t)
  setup(t, 2)
  local a = t:put(12, 0, "lrig_deck")  -- ウリス Lv1, 【アタックフェイズ】만
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_GROW, a) == nil, "메인 페이즈에는 못 한다")
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  local g = t:action(ACT_GROW, a, "lrig_assist_right")
  t:expect(g ~= nil, "프리어택 스텝")
  -- 상대 턴 디펜스 스텝
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  t:put(1, 1, "lrig_center")
  t:put(1, 0, "lrig_center")
  t:put(3, 0, "lrig_assist_right")
  a = t:put(12, 0, "lrig_deck")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:request().player == 0)
  t:expect(t:answer(t:action(ACT_GROW, a, "lrig_assist_right")))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(a, 0, "lrig_assist_right"))
end)

case("assist: 그로우 코스트 선택 중 취소하면 아무것도 바뀌지 않는다", "설계: 확정 전 취소", function(t)
  setup(t, 2)
  local a1 = t:put(10, 0, "lrig_assist_left")
  local a2 = t:put(11, 0, "lrig_deck")
  local e = t:put(100, 0, "ena")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_GROW, a2)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().cancelable)
  t:expect(t:cancel())
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a2, 0, "lrig_deck") and t:is_in(a1, 0, "lrig_assist_left") and t:is_in(e, 0, "ena"))
end)

case("assist: 어시스트 루리그의 리미트도 합산한다", "용어집: リミット", function(t)
  local function playable(assist_cid)
    setup(t, 3)
    t:lrig(1, 3, 6, {"タマ"})  -- 센터 리미트 6
    t:start()
    t:fill(100, 0, "main_deck", 5)
    t:fill(100, 1, "main_deck", 5)
    t:put(1, 0, "lrig_center")
    t:put(assist_cid, 0, "lrig_assist_left")
    t:signi(103, 1000, COLOR_WHITE, 3)
    t:put(103, 0, "signi_left")
    t:put(103, 0, "signi_right")
    local s = t:put(100, 0, "hand")  -- 3 + 3 + 1 = 7
    t:begin(0, PHASE_MAIN)
    t:wait(HINT_MAIN)
    return t:action(ACT_PLAY, s) ~= nil
  end
  t:expect(playable(11), "어시스트 리미트 1: 6 + 1 = 7")
  t:expect(not playable(2), "어시스트 리미트 0: 7 > 6")
end)

-- 팀
local TEAM_ABILITY = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCondition(function(e,tp) return Duel.IsTeam(tp,"アンシエント・サプライズ") end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

case("team: 루리그 3체가 모두 그 팀이면 성립, 1체뿐이면 불성립", "용어집: チームアイコン, WXDi-D01-004 FAQ 1", function(t)
  local T = {"アンシエント・サプライズ"}
  t:card{cid = 20, type = TYPE_LRIG, level = 0, classes = {"アト"}, teams = T}
  t:card{cid = 21, type = TYPE_LRIG, level = 0, classes = {"タウィル"}, teams = T}
  t:card{cid = 22, type = TYPE_LRIG, level = 0, classes = {"ウムル"}, teams = T}
  t:card{cid = 23, type = TYPE_LRIG, level = 0, classes = {"ウムル"}}
  t:card{cid = 30, power = 1000, level = 0}
  t:script(30, TEAM_ABILITY)
  local function team(lrigs)
    t:start()
    t:fill(30, 0, "main_deck", 5)
    t:fill(30, 1, "main_deck", 5)
    local zones = {"lrig_center", "lrig_assist_left", "lrig_assist_right"}
    for i, cid in ipairs(lrigs) do t:put(cid, 0, zones[i]) end
    local s = t:put(30, 0, "signi_center")
    t:begin(0, PHASE_MAIN)
    t:wait(HINT_MAIN)
    return t:action(ACT_ABILITY, s) ~= nil
  end
  t:expect(team{20, 21, 22}, "3체 모두 팀")
  t:expect(not team{20}, "1체뿐")
  t:expect(not team{20, 21, 23}, "한 체가 다른 팀")
end)

case("team: DB의 D01 레벨 0 루리그 3체는 アンシエント・サプライズ", "WXDi-D01-001·005·008 チーム, system_update 「チーム名の追加」", function(t)
  t:card{cid = 30, power = 1000, level = 0}
  t:script(30, TEAM_ABILITY)
  t:start{db = true}
  t:fill(30, 0, "main_deck", 5)
  t:fill(30, 1, "main_deck", 5)
  t:put(t:no("WXDi-D01-001"), 0, "lrig_center")
  t:put(t:no("WXDi-D01-005"), 0, "lrig_assist_left")
  t:put(t:no("WDK09-005"), 0, "lrig_assist_right")  -- 키 시리즈 카드에도 팀이 붙었다
  local s = t:put(30, 0, "signi_center")
  t:begin(0, PHASE_MAIN)
  t:wait(HINT_MAIN)
  t:expect(t:action(ACT_ABILITY, s) ~= nil)
end)

-- 에나 지불
local RED_SPELL = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

local MULTI_ENA = [[
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】【マルチエナ】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
end
]]

local function pay_case(t, cost, ena_cid)
  t:lrig(1, 3, 9, {"タマ"})
  t:card{cid = 400, type = TYPE_SPELL, cost = cost}
  t:script(400, RED_SPELL)
  t:signi(100, 1000)
  t:start{db = true}
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  t:put(1, 0, "lrig_center")
  local spell = t:put(400, 0, "hand")
  local e = t:put(ena_cid, 0, "ena")
  t:begin(0, PHASE_MAIN)
  t:wait(HINT_MAIN)
  return spell, e
end

case("ena: 【マルチエナ】는 에나에서 아무 색으로나 낸다", "용어집: マルチエナ, WXDi-D01-020", function(t)
  t:card{cid = 50, power = 1000, level = 1, color = 0}
  t:script(50, MULTI_ENA)
  local spell, e = pay_case(t, "{R}", 50)
  local act = t:action(ACT_USE, spell)
  t:expect(act ~= nil)
  t:expect(t:answer(act))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(spell, 0, "trash"))
end)

case("ena: 【マルチエナ】는 에나가 아니면 없다", "용어집: マルチエナ(エナゾーンでのみ機能)", function(t)
  t:card{cid = 50, power = 1000, level = 1, color = 0}
  t:script(50, MULTI_ENA)
  local spell = pay_case(t, "{R}", 100)
  t:put(50, 0, "hand")
  t:expect(t:action(ACT_USE, spell) == nil)
end)

case("ena: 두 색 카드(幻水 スイギュウ)는 둘 중 한 색으로 낸다", "WXDi-D01-018", function(t)
  local spell = pay_case(t, "{G}", 891)
  t:expect(t:action(ACT_USE, spell) ~= nil, "녹")
  spell = pay_case(t, "{U}", 891)
  t:expect(t:action(ACT_USE, spell) ~= nil, "청")
  spell = pay_case(t, "{R}", 891)
  t:expect(t:action(ACT_USE, spell) == nil, "적은 안 된다")
end)

-- 엔나차지
case("ena: 【エナチャージ】 도중 덱이 없어지면 거기서 끝, 그 뒤 리프레시", "WXDi-D01-013 FAQ 1, 용어집: エナチャージ", function(t)
  t:lrig(1, 3, 9, {"タマ"})
  t:card{cid = 401, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(401, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) CHARGED = Duel.EnaCharge(tp,3):GetCount() end)
  c:RegisterEffect(e1)
end
]])
  t:signi(100, 1000)
  t:start()
  t:fill(100, 0, "main_deck", 2)
  t:fill(100, 0, "trash", 5)
  t:fill(100, 1, "main_deck", 5)
  t:put(1, 0, "lrig_center")
  local arts = t:put(401, 0, "lrig_deck")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("CHARGED") == 2)
  t:expect(t:count(0, "ena") == 2, "남은 1장은 리프레시 뒤에 놓지 않는다")
  t:expect(t:refreshes(0) == 1)
end)
