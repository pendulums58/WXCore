-- WX18-041 コードメイズ　サイスパ
-- 【起】《アタックフェイズアイコン》《白》トラッシュにあるこのカードをゲームから除外する：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失い、新たに得られない。この能力はあなたのセンタールリグが＜イオナ＞の場合にしか使用できない。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失い、新たに得られない。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{W}")
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_IONA) end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_TRASH) end
    Duel.Exclude(e:GetHandler())
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1) end
  end)  -- [まで] 「新たに得られない」는 근사
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
