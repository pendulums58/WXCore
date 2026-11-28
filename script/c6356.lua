-- WXK02-080 中装　キツネサキ
-- 【自】《ターン１回》：あなたが手札から＜アーム＞のシグニを１枚捨てたとき、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 여러 장이면 1번만(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) for x in eg:Iter() do if x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_HAND) and r&REASON_DISCARD~=0 and (function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end)(x) then return true end end return false end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
