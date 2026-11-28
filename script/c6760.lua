-- WXK07-062 羅原　Ddn
-- 【出】他の＜原子＞のシグニ２体を場からトラッシュに置く：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    local sg=Duel.SelectCards(tp,g,2,2)
    
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e1)
end
