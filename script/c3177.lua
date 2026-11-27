-- WX21-012 青幻水　ケートス
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜水獣＞のシグニをあなたの手札と場からトラッシュに置く
-- 【自】：あなたのアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- 【自】：対戦相手のアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_SUIJU),LOCATION_HAND+LOCATION_SZONE)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e2)
end
