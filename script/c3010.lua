-- WX18-059 幻怪　イポダラ
-- 【自】：あなたの＜怪異＞のシグニ１枚が対戦相手の効果によって手札からトラッシュに置かれたとき、カードを１枚引いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() return x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) and x:IsPreviousLocation(LOCATION_HAND) and rp~=tp and r&REASON_EFFECT~=0 end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
