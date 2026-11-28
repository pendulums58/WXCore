-- PR-K066 歳月不待（ウィクロスマガジン2019 Autumn 付録）
-- あなたのすべてのシグニを場からトラッシュに置き、手札をすべて捨てる。その後、カードを５枚引き、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    Duel.Draw(tp,5)
    Duel.SendToLife(Duel.GetDecktopGroup(tp,1))
  end)
  c:RegisterEffect(e1)
end
