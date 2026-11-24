-- 능력의 분류(ABILITY_*): 【自】·【出】·【起】·【常】

case("능력 분류: 모든 스크립트의 분류가 카드 텍스트와 맞는다", "설계: 능력 분류", function(t)
  t:start{db = true, seed = 1}
  local marks = {}
  for head, kind in pairs{["自"] = ABILITY_AUTO, ["出"] = ABILITY_ON_PLAY, ["起"] = ABILITY_IGNITION, ["常"] = ABILITY_CONTINUOUS} do
    for _, pre in ipairs{"", "クロス", "チーム"} do marks["【" .. pre .. head .. "】"] = kind end
  end
  marks["【トラップアイコン】"] = ABILITY_TRAP
  local function mark(text)
    local _, e = text:find("】", 1, true)
    return e and marks[text:sub(1, e)]
  end
  local n = 0
  for _, cid in ipairs(t:script_cids()) do
    do
      local c = t:put(cid, 0, "exclude")
      for _, a in ipairs(t:abilities(c)) do
        local text = a.desc % 32 >= 16 and a.desc % 32 < 31 and t:desc_text(a.desc) or ""
        local want = mark(text)
        if want then
          n = n + 1
          t:expect(a.type == want, ("c%d: %s (분류 %d)"):format(cid, text:sub(1, 60), a.type))
        elseif a.desc ~= 0 and a.type ~= 0 then
          t:expect(a.type == ABILITY_USE, ("c%d: 표시가 없는 문장인데 분류 %d: %s"):format(cid, a.type, text:sub(1, 60)))
        end
      end
    end
  end
  t:expect(n > 100, "검사한 능력 " .. n)
end)

-- 한 카드에 【自】(어택)·【出】·【起】·【常】을 다 넣고 분류 하나씩 막는다
local ALL = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp) Duel.EnaCharge(tp,1) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp) end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetCode(EFFECT_UPDATE_POWER)
  e4:SetRange(LOCATION_SZONE)
  e4:SetValue(1000)
  c:RegisterEffect(e4)
end
]]

case("능력 분류: 막힌 분류만 쓸 수 없다", "설계: 능력 분류", function(t)
  for _, kind in ipairs{0, ABILITY_AUTO, ABILITY_ON_PLAY, ABILITY_IGNITION, ABILITY_CONTINUOUS} do
    t:lrig(1, 3, 9, {"タマ"})
    t:signi(100, 5000)
    t:signi(300, 1000)
    t:script(300, ALL)
    t:start()
    t:fill(100, 0, "main_deck", 10)
    t:fill(100, 1, "main_deck", 10)
    t:fill(100, 1, "life_cloth", 3)
    t:put(1, 0, "lrig_center")
    local h = t:put(300, 0, "hand")
    if kind ~= 0 then t:field(819, kind, 0, LOCATION_SZONE, 0, 0) end
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:answer(t:action(ACT_PLAY, h, "signi_left")))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "ena") == (kind == ABILITY_ON_PLAY and 0 or 1), "【出】 " .. kind)
    t:expect((t:action(ACT_ABILITY, h) == nil) == (kind == ABILITY_IGNITION), "【起】 " .. kind)
    t:expect(t:power(h) == (kind == ABILITY_CONTINUOUS and 1000 or 2000), "【常】 " .. kind)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(h))
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "hand") == (kind == ABILITY_AUTO and 0 or 1), "【自】 " .. kind)
  end
end)
