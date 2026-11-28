-- WXK06-016 カウンター・アクセント
-- このアーツの使用コストはあなたの場にあるシグニ１体につき《青×1》減る。
-- スペル１つを対象とし、それの効果を打ち消す。そうした場合、カードを１枚引き、このカードをルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    if not Duel.GetCutinSpell() then return end
    Duel.NegateSpell()
    Duel.Draw(tp,1)
    local me=e:GetHandler()
    if me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{U}",Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()) end)
end
