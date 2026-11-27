-- WX03-021 ロスト・テクノロジー
-- あなたのすべてのシグニを場からトラッシュに置いてもよい。この方法で３体の＜古代兵器＞のシグニがトラッシュに置かれた場合、対戦相手のライフクロス２枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    -- 「置いてもよい」(FAQ 2)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local t=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) end,nil)
    if t:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,nil):GetCount()==3 then Duel.Crush(1-tp,2) end
  end)
  c:RegisterEffect(e1)
end
