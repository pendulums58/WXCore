-- WX13-035 参ノ遊　ゴガツドール
-- 【自】：このシグニがアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【出】：このシグニがアタックフェイズの間に場に出た場合、あなたのデッキの上からカードを３枚エナゾーンに置く。
-- ライフバースト：あなたのデッキの上からカードを２枚見る。その中から１枚を手札に加えるかエナゾーンに置く。残りをデッキの一番上か一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function() return Duel.GetPhase()==PHASE_ATTACK end)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,3)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    -- 예 = 패, 아니오 = 에나
    if Duel.SelectYesNo(tp) then Duel.SendToHand(x) else Duel.SendToEna(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil):GetFirst()
    if rest and not Duel.SelectYesNo(tp) then Duel.SendToDeckBottom(Group.CreateGroup(rest),false) end
  end)
  c:RegisterEffect(e3)
end
