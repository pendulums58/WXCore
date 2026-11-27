-- WX16-010 コール・ワンダー
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのデッキから＜怪異＞のシグニ１枚を探して場に出し、デッキをシャッフルする。あなたがベットしていた場合、代わりに＜怪異＞のシグニを２枚まで探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,Duel.IsBet() and 2 or 1)
    for x in g:Iter() do Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
