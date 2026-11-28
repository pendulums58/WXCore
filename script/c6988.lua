-- WXK10-014 ハイマット・レイ
-- あなたのセンタールリグ１体を対象とし、ターン終了時まで、それは
-- 「【起】《ターン１回》《アタックフェイズアイコン》エクシード１：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。」
-- 「【起】《ターン２回》《アタックフェイズアイコン》エクシード１：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。」
-- 「【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、それをダウンする。」
-- を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_LRIG,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local function grant(g) local e1=Effect.CreateEffect(e:GetHandler()) e1:SetType(EFFECT_TYPE_SINGLE) e1:SetCode(EFFECT_GRANT) e1:SetLabelObject(g) e1:SetReset(RESET_PHASE+PHASE_END) tc:GrantEffect(e1) end
      local g1=Effect.CreateEffect(e:GetHandler())
      g1:SetType(EFFECT_TYPE_IGNITION)
      g1:SetDescription(aux.Stringid(id,0))
      g1:SetRange(LOCATION_LRIG)
      g1:SetTiming(TIMING_ATTACK)
      g1:SetCountLimit(1)
      g1:SetExceedCost(1)
      g1:SetOperation(function(e,tp) local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if x then local e1=Effect.CreateEffect(e:GetHandler()) e1:SetType(EFFECT_TYPE_SINGLE) e1:SetCode(EFFECT_LOSE_ABILITY) e1:SetReset(RESET_PHASE+PHASE_END) x:GrantEffect(e1) end end)
      grant(g1)
      local g2=Effect.CreateEffect(e:GetHandler())
      g2:SetType(EFFECT_TYPE_IGNITION)
      g2:SetDescription(aux.Stringid(id,1))
      g2:SetRange(LOCATION_LRIG)
      g2:SetTiming(TIMING_ATTACK)
      g2:SetCountLimit(2)
      g2:SetExceedCost(1)
      g2:SetOperation(function(e,tp) local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.SendToHand(x) end end)
      grant(g2)
      local g3=Effect.CreateEffect(e:GetHandler())
      g3:SetType(EFFECT_TYPE_IGNITION)
      g3:SetDescription(aux.Stringid(id,2))
      g3:SetRange(LOCATION_LRIG)
      g3:SetTiming(TIMING_ATTACK)
      g3:SetExceedCost(2)
      g3:SetOperation(function(e,tp) local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if x then Duel.Down(x) end end)
      grant(g3)
    end
  end)
  c:RegisterEffect(e1)
end
