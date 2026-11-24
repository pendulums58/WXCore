-- WD21-014 羅星　≡レグルス≡
-- 【起】《ダウン》：カードを１枚引く。この能力は対戦相手の場にレベル３以上のシグニがある場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp)
    return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()>=3 end,tp,0,LOCATION_SZONE,nil):GetCount()>0
  end)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
