-- WX21-029 閃英の発明　＃エディソン＃
-- 【常】：アタックフェイズの間、あなたの【英知】能力の条件がこのシグニのレベルを参照する場合、このシグニのレベルは１～９であるとして扱う。
-- 【出】英知＝８：対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
-- 【自】英知＝１２：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：【エナチャージ３】
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「アタックフェイズの間、【英知】の条件でレベルは１～９」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(8))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.EichiCon(12))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,3)
  end)
  c:RegisterEffect(e3)
end
