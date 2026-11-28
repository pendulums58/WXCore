-- WXK06-043 コードメイズ　シャウエン
-- 【自】：対戦相手のアタックフェイズ開始時、あなたのすべてのシグニを好きなように配置し直す。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 「好きなように配置し直す」(근사: 두 체의 자리를 한 번 바꿔도 된다)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    local t=Duel.SelectCards(tp,g,2,2)
    local a=t:GetFirst()
    local b=nil
    for x in t:Iter() do if x~=a then b=x end end
    Duel.SwapSigni(a,b)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
