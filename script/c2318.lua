-- WX08-072 解決
-- あなたのデッキからカード１枚を探してエナゾーンに置く。あなたの場にクロス状態のシグニがある場合、追加であなたのデッキからカード１枚を探してエナゾーンに置く。その後、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから《クロスアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local n=(Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0) and 2 or 1
    local g=aux.Search(tp,nil,n)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,1)
  end)
  c:RegisterEffect(e2)
end
