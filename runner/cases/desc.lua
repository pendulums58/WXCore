-- 효과 설명 번호(desc): 요청·트리거에 「어느 효과인가」를 싣는다(설계: 효과 설명 문자열)
-- desc = cid × 32 + slot. slot 0~15 = str, 16~30 = 능력 줄 0~14, 31 = 라이프 버스트

local function base(t)
  t:lrig(1, 3, 9, {"タマ"})
  t:signi(100, 5000)
end

local function stock(t)
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
end

-- 상대 시그니가 어택하면 트리거(강제). 능력 줄 n번
local function on_opp_attack(n)
  return ([[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetDescription(id*32+16+%d)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()~=tp end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]):format(n)
end

case("desc: 동시 트리거 순서의 선택지마다 그 효과의 설명 번호", "설계: 효과 설명 문자열", function(t)
  base(t)
  t:signi(311, 1000)
  t:script(311, on_opp_attack(0))
  t:signi(312, 1000)
  t:script(312, on_opp_attack(2))
  t:start()
  stock(t)
  local a = t:put(100, 0, "signi_left")
  t:put(311, 1, "signi_left")
  t:put(312, 1, "signi_center")
  t:fill(100, 1, "life_cloth", 3)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_TRIGGER_ORDER))
  local d = t:request().option_descs
  t:expect(d[1] == 311 * 32 + 16 and d[2] == 312 * 32 + 18, "능력 줄 0번·2번")
end)

case("desc: 「능력을 발동할까?」와 그 효과 처리 중의 요청에 설명 번호", "설계: 효과 설명 문자열", function(t)
  base(t)
  t:signi(304, 1000)
  t:script(304, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetDescription(id*32+17)
  e1:SetOperation(function(e,tp) Duel.SelectOption(tp,id*32+0,id*32+1,"test") end)
  c:RegisterEffect(e1)
end
]])
  t:start()
  stock(t)
  t:put(1, 0, "lrig_center")
  local c = t:put(304, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_PLAY, c, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:request().source == c and t:request().source_desc == 304 * 32 + 17)
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MODE))
  local r = t:request()
  t:expect(r.source == c and r.source_desc == 304 * 32 + 17, "처리 중인 효과의 것")
  t:expect(r.option_descs[1] == 304 * 32 and r.option_descs[2] == 304 * 32 + 1 and r.option_descs[3] == 0,
           "모드는 str 번호, 문자열을 넘기면 0")
end)

case("desc: 라이프 버스트는 설명을 안 붙여도 LB 문장(slot 31)", "설계: 효과 설명 문자열", function(t)
  base(t)
  t:card{cid = 302, power = 1000, level = 1, burst = 1}
  t:script(302, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]])
  t:start()
  stock(t)
  local a = t:put(100, 0, "signi_left")
  t:put(100, 1, "life_cloth")
  t:put(302, 1, "life_cloth")  -- 맨 위
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:request().source_desc == 302 * 32 + 31)
end)
