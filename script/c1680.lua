-- WDK09-006 ブリリアント・エコー
-- アンコール －《コインアイコン》《コインアイコン》
-- 対戦相手のシグニゾーン１つに【ゲート】１つを置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)  -- 코스트와 같이 낸다(FAQ 2). 루리그 트래시에서는 낼 수 없다(FAQ 3)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local zones={}
  for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
    if not Duel.HasGate(z) then zones[#zones+1]=z end
  end
  local z=Duel.SelectZone(tp,zones)
  if z then Duel.PlaceGate(z) end
end
