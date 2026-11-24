-- WD23-030-E ＳＰＡＤＥ　ＷＯＲＫ
-- あなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから【ライフバースト】を持つ無色ではないカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 바니시하지 못하면 뒷부분은 하지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0) then return end
    aux.SearchToHand(tp,function(x) return x:IsLifeBurst() and x:GetColor()~=0 end,1)
  end)
  c:RegisterEffect(e1)
end
