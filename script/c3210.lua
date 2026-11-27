-- WX21-049 幻怪　ヒトダマ
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《ダウン》：シグニ１体を対象とし、ターン終了時まで、それはクラスを失い、＜怪異＞を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 【起】 「クラスを失い＜怪異＞を得る」: ＜怪異＞를 더하는 것으로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CLASS)
    e1:SetValue(RACE_KAII)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
