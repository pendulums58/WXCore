-- WX21-010 黒白混轟
-- 同じパワーを持つ対戦相手のシグニ２体を対象とし、それらをバニッシュする。その後、それらに白か黒のシグニが１体以上含まれる場合、対戦相手は自分のエナゾーンからカード２枚を対象とし、それらをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(sg) return sg:GetCount()<2 or (function() local a,b for x in sg:Iter() do if a then b=x else a=x end end return a:GetPower()==b:GetPower() end)() end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetTargets():GetCount()<2 then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local hit=g:Filter(function(x) return x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK) end,nil):GetCount()>0
    if g:GetCount()>0 then Duel.Banish(g) end
    if hit then
      local en=Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,2,2,nil)
      if en:GetCount()>0 then Duel.SendToTrash(en,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e1)
end
