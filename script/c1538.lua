-- WDK-F03-13 讃の遊　パックンチョ
-- 【自】：このシグニがアタックしたとき、このシグニを場から手札に戻してもよい。そうした場合、あなたのデッキの一番上を公開する。それがシグニの場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 시그니가 아니면 덱 위에 뒷면으로 남고, 돌아간 이 시그니도 그대로(FAQ 1). 빈 시그니 존 어디든(FAQ 2)
function s.op(e,tp)
  local c=e:GetHandler()
  if not (c:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
  Duel.SendToHand(c)
  if not c:IsLocation(LOCATION_HAND) then return end
  local top=Duel.GetDecktopGroup(tp,1):GetFirst()
  if not top then return end
  Duel.RevealCards(top)
  if top:IsSigni() then Duel.PutOnField(top,tp) end
end
