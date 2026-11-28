-- WXK07-064 羅原　Fg
-- 【出】他の＜原子＞のシグニ１体を場からトラッシュに置く：【エナチャージ１】
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=1 end
    local sg=Duel.SelectCards(tp,g,1,1)
    
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
