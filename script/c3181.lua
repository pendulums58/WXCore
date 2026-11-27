-- WX21-016 バッド・カラー
-- 対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。その後、それが青か緑のシグニの場合、追加であなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local hit=tc:IsColor(COLOR_BLUE) or tc:IsColor(COLOR_GREEN)
    Duel.Banish(tc)
    if hit then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.SendToHand(x) end end
  end)
  c:RegisterEffect(e1)
end
