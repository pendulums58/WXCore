-- WX15-022 君子豹変
-- あなたのデッキから《アクセアイコン》を持つシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:HasAcceIcon() end,1)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
