-- WX15-015 タスク・ドロー
-- ベット―《コインアイコン》《コインアイコン》
-- カードを２枚引く。あなたがベットしていた場合、代わりにカードを４枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,Duel.IsBet() and 4 or 2)
  end)
  c:RegisterEffect(e1)
end
