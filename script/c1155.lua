-- WD07-006 グレイブ・ナイト
-- あなたのデッキからそれぞれレベルの異なるシグニを３枚まで探してトラッシュに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.distinct(g)
  local lv={}
  for x in g:Iter() do
    if lv[x:GetLevel()] then return false end
    lv[x:GetLevel()]=true
  end
  return true
end
function s.op(e,tp)
  Duel.SetSelectCheck(s.distinct)
  local g=aux.Search(tp,Card.IsSigni,3)
  if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  aux.ShuffleDeck(tp)
end
