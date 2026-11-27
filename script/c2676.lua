-- WX14-012 炎軍奮闘
-- 手札を２枚捨てる。そうした場合、あなたのデッキからカード名に《フレイスロ》を含むシグニを２枚まで探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<2 or aux.Discard(tp,2)<2 then return end
    local g=aux.Search(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,2)
    for x in g:Iter() do Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
