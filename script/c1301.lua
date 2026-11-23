-- WD19-015 羅菌　クロコウジ
-- 【出】：対戦相手の場に【ウィルス】がない場合、対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 「対戦相手の場」는 상대 시그니 존 3개 전부: 어디에도 【ウィルス】가 없을 때만(FAQ 1)
function s.op(e,tp)
  local zones=Duel.GetSigniZones(1-tp)
  for _,z in ipairs(zones) do
    if Duel.HasVirus(z) then return end
  end
  local z=Duel.SelectZone(tp,zones)
  if z then Duel.PlaceVirus(z) end
end
