-- WXEX1-54 羅星　ジュメニーズ
-- 【出】：対戦相手の凍結状態のシグニ１体を対象とし、それを手札に戻す。
-- 【起】《メインフェイズ》《アタックフェイズ》トラッシュにあるこのカードをゲームから除外する：対戦相手のシグニを２体まで対象とし、それらを凍結する。この能力はあなたのセンタールリグが＜リメンバ＞の場合にしか使用できない。
-- 【常】：【コンバート《青》】（エナコストを支払う際、このカードは《青》として支払える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCondition(function(e,tp)
    local l=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    return l and l:IsLrigType(LRIG_REMEMBER)
  end)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Exclude(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do Duel.Freeze(x) end
  end)
  c:RegisterEffect(e2)
  -- [の間] 【常】 【コンバート《青》】
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_ADD_PAY_COLOR)
  e3:SetRange(LOCATION_ENA)
  e3:SetValue(COLOR_BLUE)
  c:RegisterEffect(e3)
end
