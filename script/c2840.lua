-- WX16-015 とつげきあーや！I
-- 【出】《コインアイコン》：あなたのデッキの一番上を見る。あなたはそのカードを【トラップ】としてあなたのシグニゾーンに設置してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if Duel.SelectYesNo(tp) then Duel.SetTrap(x,tp) end
  end)
  c:RegisterEffect(e1)
end
