-- WXEX1-10 コード・ピルルク　ＥＣ
-- 【出】：対戦相手は手札を１枚捨てる。あなたのトラッシュに＜電機＞のシグニが６枚以上ある場合、カードを２枚引く。
-- 【起】《ターン１回》《アタックフェイズアイコン》手札から＜電機＞のシグニを２枚捨てる：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
-- 【起】《コインアイコン》：次のターンの間、対戦相手はカードを合計１枚までしか引けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,1)
    if Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_DENKI),tp,LOCATION_TRASH,0,nil):GetCount()>=6 then
      Duel.Draw(tp,2)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(2,aux.ClassFilter(0,RACE_DENKI)))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    local nxt=Duel.GetTurnCount()+1
    -- [の間] 「次のターンの間、対戦相手はカードを合計１枚までしか引けない」(드로 페이즈 1장 제한으로 근사)
    local ef=Effect.CreateEffect(e:GetHandler())
    ef:SetType(EFFECT_TYPE_FIELD)
    ef:SetCode(EFFECT_DRAW_PHASE_COUNT)
    ef:SetTargetRange(0,1)
    ef:SetValue(1)
    ef:SetCondition(function() return Duel.GetTurnCount()==nxt end)
    ef:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(ef,tp)
  end)
  c:RegisterEffect(e3)
end
