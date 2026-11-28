-- WXK07-040 羅原　Sk
-- 【出】他の＜原子＞のシグニ１体を場からトラッシュに置く：この方法でトラッシュに置いたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
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
    e:SetLabel(sg:GetFirst():GetLevel())
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local lv=e:GetLabel()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
