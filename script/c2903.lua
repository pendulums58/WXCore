-- WX17-010 ゼノエクスプレス
-- ベット―《コインアイコン》
-- あなたのデッキから白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。あなたがベットしていた場合、追加であなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,1)
    if Duel.IsBet() then aux.SearchToHand(tp,Card.IsSigni,1) end
  end)
  c:RegisterEffect(e1)
end
