-- WX13-047 同砲の紲絆
-- あなたの《クロスアイコン》を持つシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから《クロスアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.Banish(tc)>0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,1) end end
  end)
  c:RegisterEffect(e1)
end
