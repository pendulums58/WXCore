-- WX16-061 中罠　ニセラブ
-- 【出】：あなたの【トラップ】１つをトラッシュに置く。そうした場合、あなたのデッキの上からカードを３枚見て、その中から１枚を【トラップ】としてあなたのシグニゾーンに設置し、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)==0 then return end
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
