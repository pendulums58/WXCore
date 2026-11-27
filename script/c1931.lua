-- WX02-043 コードアンチ　キティラ
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚公開する。その中から＜古代兵器＞のシグニ１枚を手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local f=function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end
    local pick=Duel.SelectCards(tp,g:Filter(f,nil),math.min(1,g:Filter(f,nil):GetCount()),1)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
