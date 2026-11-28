-- WXK03-039 最英の相棒　ワトソン
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのデッキの下からカードを４枚トラッシュに置く。この方法でそれぞれレベルの異なるシグニ４枚がトラッシュに置かれた場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDeckbottomGroup(tp,4)
    local ok=false
    if g:GetCount()>0 then
      Duel.SendToTrash(g,REASON_EFFECT)
      local t=g:Filter(function(x) return x:IsSigni() and x:IsLocation(LOCATION_TRASH) end,nil)
      ok=t:GetCount()==4 and aux.DistinctLevels(t)
    end
    local tc=Duel.GetFirstTarget()
    if ok and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
