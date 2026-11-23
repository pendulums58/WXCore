-- WD01-015 ゲット・バイブル
-- あなたのデッキからシグニを１枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 있어도 찾지 않았다고 하고 섞기만 해도 된다(FAQ 1)
function s.op(e,tp)
  Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
  local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_MDECK,0,nil),0,1)
  if g:GetCount()>0 then
    Duel.RevealCards(g)
    Duel.SendToHand(g)
  end
  Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
end
