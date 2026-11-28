-- WXK04-019 ゼラチン・ボディ
-- ベット―《コインアイコン》《コインアイコン》
-- このターン、次にあなたがダメージを受ける場合、代わりにダメージを受けない。あなたがベットしていた場合、代わりにこのターン、次とその次にあなたがダメージを受ける場合、代わりにダメージを受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp,eg)
    for _=1,(Duel.IsBet() and 2 or 1) do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
