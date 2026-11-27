-- WX14-076 幻蟲　モスキート
-- 【起】《ダウン》：対象の対戦相手のトラッシュのカード１枚を対象の対戦相手のシグニ１体の【チャーム】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.c=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil):GetFirst()
    s.h=Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.c and s.h and s.c:IsRelateToEffect(e) and s.h:IsRelateToEffect(e) and not s.h:GetCharm() then Duel.Charm(s.c,s.h) end
  end)
  c:RegisterEffect(e1)
end
