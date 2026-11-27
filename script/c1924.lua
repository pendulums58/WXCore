-- WX02-035 コードアート　Ｃ・Ｐ・Ｕ
-- 【出】手札から＜電機＞のシグニを１枚捨てる：対戦相手のシグニ１体を対象とし、それを凍結する。カードを１枚引く。
-- （凍結されたシグニは次のアップフェイズにアップしない）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Freeze(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
