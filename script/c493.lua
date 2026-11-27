-- WX03-015 デス・コロッサオ
-- あなたのすべてのシグニを場からトラッシュに置いてもよい。この方法でそれぞれがレベルの異なるシグニが３体トラッシュに置かれた場合、対戦相手のすべてのシグニをバニッシュする。
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
    -- 장의 시그니만(FAQ 1)
    if t:GetCount()==3 and aux.DistinctLevels(t) then
      local og=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if og:GetCount()>0 then Duel.Banish(og) end
    end
  end)
  c:RegisterEffect(e1)
end
