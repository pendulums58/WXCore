-- WXEX1-27 緑伍ノ遊　フラコスタ
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜遊具＞のシグニをあなたのエナゾーンと場からトラッシュに置く
-- 【起】《ターン１回》《緑×0》：対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。【エナチャージ１】をする。
-- 【起】《ターン１回》《アタックフェイズアイコン》《緑×0》：あなたの＜遊具＞のシグニ１体を対象とし、ターン終了時まで、それは「【常】：対戦相手の効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_YUGU),LOCATION_ENA+LOCATION_SZONE,TIMING_MAIN)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_YUGU),tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] 「【常】：対戦相手の効果を受けない。」を得る
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE)
      g:SetCode(EFFECT_IMMUNE)
      g:SetValue(function(e2,sc,sp) return sp~=tp end)
      g:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e2)
end
