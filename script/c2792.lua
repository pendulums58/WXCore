-- WX15-076 羅星　≡アルマク≡
-- 【起】《ダウン》エナゾーンから＜宇宙＞のシグニ１枚をトラッシュに置く：対戦相手のパワー7000以下のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
