-- WX11-045 肆ノ遊　タコアゲ
-- 【自】：このシグニが効果によって場に出たとき、あなたのシグニ１体を対象とし、それをアップする。
-- 【自】：このシグニが効果によってバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：どちらか１つを選ぶ。①あなたのエナゾーンからシグニを２枚まで対象とし、それらを手札に加える。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetAbilityType(ABILITY_AUTO)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT~=0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT~=0 end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,2,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
