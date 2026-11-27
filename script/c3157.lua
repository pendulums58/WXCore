-- WX20-071 コードイート　ツキミダンゴ
-- 【自】：対戦相手のターンの間、このシグニが場を離れたとき、このシグニがアクセされていた場合、あなたのデッキの一番上のカードをエナゾーンに置き、カードを１枚引き、手札から＜調理＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsPreviousAcce() end)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    Duel.Draw(tp,1)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
