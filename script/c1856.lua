-- WX01-046 ＢＡＤ　ＣＯＮＤＩＴＩＯＮ
-- このカードは対戦相手の手札が０枚の場合にしか使用できない。
-- 対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()==0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
