-- WX22-036 幻竜　ピュートン
-- 【自】：このカードがあなたの＜龍獣＞のシグニの効果によって手札から公開されたとき、あなたの手札から《幻竜　ピュートン》１枚を場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re) return re~=nil and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(re:GetHandler()) end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsCardName(id) end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
