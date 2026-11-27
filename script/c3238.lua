-- WX22-013 真幸の冥者　ハナレ
-- 【常】：対戦相手の効果によって、シグニのパワーは＋（プラス）されない。
-- 【自】《ターン１回》：対戦相手のシグニのパワーが０以下になったとき、あなたのデッキの一番上のカードをエナゾーンに置くか、カードを１枚引く。
-- 【出】：あなたのトラッシュから＜毒牙＞のシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《アタックフェイズアイコン》エクシード１：対戦相手のシグニ１体を対象とし、ターン終了時まで、それの基本パワーを０にする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「対戦相手の効果によって、シグニのパワーは＋されない」는 아직(근사 없음)
  -- 「パワーが０以下になったとき」는 룰 바니시 때로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return eg:GetFirst():GetOwner()~=tp and r&REASON_RULE~=0 end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(1)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_BASE_POWER)
        e1:SetValue(0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1) end
  end)
  c:RegisterEffect(e3)
end
