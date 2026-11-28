-- WXK02-071 偉智の遊　サンポケ
-- 【自】：このシグニがアタックしたとき、このシグニを場から手札に戻してもよい。そうした場合、あなたのデッキの一番上を公開する。それがシグニの場合、それをアタックしているシグニとしてダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToHand(h)==0 then return end
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() then Duel.PutOnFieldAttacking(x,tp) end
  end)
  c:RegisterEffect(e1)
end
