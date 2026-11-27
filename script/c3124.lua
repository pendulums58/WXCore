-- WX20-031 胎動する誓約
-- あなたのデッキからシグニ１枚を探してトラッシュに置き、デッキをシャッフルする。その後、あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。このターン、あなたはスペルを使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,Card.IsSigni,1)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
    local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e2,c) return c:IsType(TYPE_SPELL) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
