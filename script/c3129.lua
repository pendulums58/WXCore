-- WX20-040 中罠　グルグル
-- 【常】：あなたの場に【トラップ】があるかぎり、このシグニのパワーは＋2000される。
-- 【自】：このシグニがアタックしたとき、あなたの場に【トラップ】が３枚以上ある場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil):GetCount()>0 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil):GetCount()>=3 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
