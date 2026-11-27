-- WX12-035 懐古の音色　リコダス
-- 【自】：対戦相手のシグニ１体がアタックしたとき、《緑》《緑》《白》を支払い、トラッシュにあるこのシグニをゲームから除外してもよい。そうした場合、そのシグニのアタックを一度無効にする。（この能力はこのシグニがトラッシュにある場合にしか発動しない）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 트래시에서만(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{G}{G}{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{W}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.Exclude(h)>0 then Duel.NegateAttack() end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
