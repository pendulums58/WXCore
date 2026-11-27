-- WX18-062 肥後の虎将　カトキヨ
-- 【自】：このカードがコストか効果によってシグニの下からトラッシュに置かれたとき、あなたのデッキの一番上のカードをエナゾーンに置くかカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&(REASON_COST+REASON_EFFECT)~=0 and e:GetHandler():GetPreviousLocation()==0 end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
