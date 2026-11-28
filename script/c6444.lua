-- WXK03-070 幻怪　モモタロ
-- 【出】エナゾーンから《幻怪　モモイヌ》１枚と《幻怪　モモザル》１枚と《幻怪　モモキジ》１枚をトラッシュに置く：対象の対戦相手のシグニ１体をエナゾーンに置き、対象の対戦相手のシグニ１体を手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 1체뿐이면 에나에(FAQ 2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local need={6447,6446,6445}
    local pick=Group.CreateGroup()
    for _,cid in ipairs(need) do
      local x=Duel.GetMatchingGroup(function(y) return y:IsCardName(cid) and not pick:IsContains(y) end,tp,LOCATION_ENA,0,nil):GetFirst()
      if not x then if chk==0 then return false end return end
      pick:AddCard(x)
    end
    if chk==0 then return true end
    Duel.SendToTrash(pick,REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local t=g:GetFirst()
    if t then Duel.SendToEna(t) end
    for x in g:Iter() do if x~=t and x:IsLocation(LOCATION_SZONE) then Duel.SendToHand(x) end end
  end)
  c:RegisterEffect(e1)
end
