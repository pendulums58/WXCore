-- WX12-Re15 コードアート　Ｄ・Ｔ・Ｐ
-- 【出】：対戦相手の場に凍結状態のシグニがある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
