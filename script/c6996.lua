-- WXK10-022 コードＶＬ　御伽原江良
-- 【自】：あなたのターンの間、対戦相手のシグニ１体が場に出たとき、ターン終了時まで、そのシグニは能力を失う。
-- 【自】：このシグニがアタックしたとき、能力を持たない対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- 【出】：あなたのデッキの一番上を公開する。それが無色ではないシグニの場合、それをエナゾーンに置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、次のあなたのターン終了時まで、それは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()==tp and x and x:GetControler()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      x:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:HasAbility() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:GetColor()~=0 then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  -- 「次のあなたのターン終了時まで」(근사: 다음 내 턴 개시까지)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_MY_TURN)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e9)
end
