-- WX22-004 全戦全焼
-- このアーツの使用コストは、あなたのルリグトラッシュにあるアーツ１枚につき《赤×1》《無×1》減る。
-- 対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) local n=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) end,tp,LOCATION_LTRASH,0,nil):GetCount() return Duel.ReduceCost(Duel.ReduceCost(base,"{R}",n),"{C}",n) end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
