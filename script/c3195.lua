-- WX21-032 禁忌の焔　≡プロメウス≡
-- 【自】：このシグニがアタックしたとき、自身のパワー以下の対戦相手のシグニ１体を対象とし、あなたの場にこのシグニと共通する色を持たない他の＜天使＞のシグニがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=e:GetHandler():GetPower() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x~=e:GetHandler() and x:GetColor()&e:GetHandler():GetColor()==0 end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
