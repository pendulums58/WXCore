-- WX06-003 火福糾縄
-- 対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。あなたのセンタールリグが赤で、あなたのライフクロスが２枚以下の場合、代わりに対戦相手のパワー15000以下のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 조건을 채우면 「代わりに」 2체까지(FAQ 1: 둘 다 대상)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_RED) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 end)() then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=15000 end,tp,0,LOCATION_SZONE,0,2,nil) else Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
