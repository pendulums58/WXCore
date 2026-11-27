-- WX21-038 ＮＯＩＳＹ
-- あなたの手札からコストの合計が３以下のスペル１枚をコストを支払わずに使用する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL) and c:GetCostTotal()<=3 end,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if x then Duel.UseFree(x,tp) end
  end)
  c:RegisterEffect(e1)
end
