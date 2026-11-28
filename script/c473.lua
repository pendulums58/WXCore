-- SP07-010 天罰覿面（「selector spread WIXOSS」 BOX2 初回限定特典）
-- 対戦相手のシグニのうち、最も大きいパワーを持つすべてのシグニを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리할 때의 파워로, 가장 큰 것 전부(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()==0 then return end
    local mx=nil
    for x in g:Iter() do if not mx or x:GetPower()>mx then mx=x:GetPower() end end
    Duel.SendToHand(g:Filter(function(x) return x:GetPower()==mx end,nil))
  end)
  c:RegisterEffect(e1)
end
