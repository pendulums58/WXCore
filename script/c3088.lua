-- WX19-068 溶英の食塩　＃ノウド＃
-- 【出】英知＝７：カードを１枚引く。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど７であるかぎり有効になる）
-- 【出】英知＝９：あなたのデッキの一番上のカードをエナゾーンに置くか、カードを１枚引く。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど９であるかぎり有効になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(7))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(aux.EichiCon(9))
  e2:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
