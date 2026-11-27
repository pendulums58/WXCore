-- WX19-044 異血之遊　†ダイショウ†
-- 【自】：このシグニがあなたの効果によって場からトラッシュに置かれたとき、あなたのレベル３の＜遊具＞のシグニ１体を対象とし、《黒》を支払ってもよい。そうした場合、それをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and r&REASON_EFFECT~=0 and rp==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and x:GetLevel()==3 end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
    if Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
      Duel.Up(tc)
    end
    end
  end)
  c:RegisterEffect(e1)
end
