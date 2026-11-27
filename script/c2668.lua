-- WX14-001 最幸の巫女　ユキ
-- 【出】：あなたのルリグトラッシュからすべてのルリグをこのカードの下に置く。
-- 【起】《ターン１回》エクシード１：対戦相手のシグニ１体を対象とし、それをデッキの一番下に置く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード１：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失い、新たに得られない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) end,tp,LOCATION_LTRASH,0,nil)
    if g:GetCount()>0 and h:IsLocation(LOCATION_LRIG) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckBottom(Group.CreateGroup(tc),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(1)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LOSE_ABILITY)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1) end
  end)  -- [まで] 「新たに得られない」는 능력 상실로 근사
  c:RegisterEffect(e3)
end
