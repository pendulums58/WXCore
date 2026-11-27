-- WX15-030 インベスト・チャージング
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのデッキの一番上のカードをエナゾーンに置く。あなたがベットしていた場合、代わりにデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,Duel.IsBet() and 2 or 1)
  end)
  c:RegisterEffect(e1)
end
