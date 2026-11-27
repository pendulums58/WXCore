-- WX15-059 コードイート　フラポテ
-- 【自】《ターン１回》：あなたのシグニ１体がアクセされたとき、あなたの手札から＜調理＞のシグニ１枚をエナゾーンに置いてもよい。そうした場合、カードを１枚引く。
-- （この効果は１ターンに一度しか発動しない。エナゾーンに置かないことを選んだ場合もそれは一度に含まれる）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()==tp end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToEna(Duel.SelectCards(tp,g,1,1))
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
