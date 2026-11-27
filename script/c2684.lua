-- WX14-020 禍因の冥者　ハナレ
-- 【自】：このカードがエクシードのコストとしてルリグトラッシュに置かれたとき、あなたのトラッシュからレベル３以下の＜毒牙＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_LTRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EXCEED~=0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
