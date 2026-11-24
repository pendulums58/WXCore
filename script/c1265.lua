-- WD15-008 龍降地固
-- あなたのエナゾーンからすべてのカードをトラッシュに置く。あなたのデッキから＜龍獣＞のシグニを２枚まで探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 에나가 0장이어도 찾을 수 있다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.SendToTrash(Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil),REASON_EFFECT)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_MDECK,0,nil),0,2)
    for tc in g:Iter() do Duel.PutOnField(tc,tp) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e1)
end
