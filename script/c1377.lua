-- WD23-017-EA クリティカル・ショット
-- ベット―《コインアイコン》《コインアイコン》《コインアイコン》
-- カードを２枚引き、手札１枚をデッキの一番上に置く。あなたがベットしていた場合、追加でデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(3)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.SendToDeckPosition(Duel.SelectCards(tp,g,1,1):GetFirst(),1) end
    if Duel.IsBet() then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e1)
end
