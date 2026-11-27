-- WX19-069 幻獣　コマドリ
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚公開する。その中から＜空獣＞のシグニ１枚と＜地獣＞のシグニ１枚を手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local a=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end,nil),0,1)
    a:Merge(Duel.SelectCards(tp,g:Filter(function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHIJU)) end)(c) and not a:IsContains(c) end,nil),0,1))
    if a:GetCount()>0 then Duel.SendToHand(a) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
