-- WXEX1-02 星占の巫女　リメンバ・ラストナイト
-- 【常】：対戦相手の凍結状態のシグニは【常】能力と【自】能力を失う。
-- 【自】：各アタックフェイズ開始時、対戦相手のシグニ１体を対象とし、それを凍結する。
-- 【起】《ターン１回》《アタックフェイズアイコン》《コインアイコン》：対戦相手の凍結状態のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DISABLE_ABILITY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsFrozen() end)
  e1:SetValue(ABILITY_CONTINUOUS+ABILITY_AUTO)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
