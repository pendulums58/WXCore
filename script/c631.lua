-- SP38-007 ヴィクティム・メモリーズ（「ウィクロス 10th Anniversary Book」付録）
-- あなたのデッキの上からカードを１０枚見る。その中からカードを１枚まで手札に加え、残りをデッキに加えてシャッフルする。
-- ライフバースト：あなたのデッキの上からカードを１０枚見る。その中からカードを１枚まで手札に加え、残りをデッキに加えてシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,10)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,10)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e2)
end
