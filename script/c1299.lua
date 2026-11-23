-- WD19-013 羅菌　ナットー
-- 【出】：対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
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
-- 【ウィルス】는 존 하나에 하나까지라 빈 존만 고른다(용어집: ウィルス)
function s.op(e,tp)
  local zones={}
  for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
    if not Duel.HasVirus(z) then zones[#zones+1]=z end
  end
  local z=Duel.SelectZone(tp,zones)
  if z then Duel.PlaceVirus(z) end
end
