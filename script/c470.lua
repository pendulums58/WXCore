-- WX04-020 千載一遇
-- あなたのデッキの上からカードを３枚公開する。その中からすべての＜美巧＞のシグニを手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local b=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil)
    local rest=g:Filter(function(x) return not b:IsContains(x) end,nil)
    if b:GetCount()>0 then Duel.SendToHand(b) end
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
