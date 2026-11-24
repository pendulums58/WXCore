-- WD12-010 参ノ遊　クルミド
-- 【自】：このシグニがあなたのエナゾーンから手札に移動したとき、あなたの手札からレベル３のシグニ１枚をダウン状態で場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- 이 카드 자신도 낼 수 있다(FAQ)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ENA) end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==3 end,tp,LOCATION_HAND,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc and Duel.PutOnField(tc,tp) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e1)
end
