-- WXK07-042 爆焼の応打
-- 好きな数のあなたの＜原子＞のシグニを対象とし、それらを場からトラッシュに置き、カードを１枚引く。その後、この方法で＜原子＞のシグニを２体以上トラッシュに置いた場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。３体トラッシュに置いた場合、追加で対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) and x:IsLocation(LOCATION_SZONE) end,nil)
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    Duel.Draw(tp,1)
    for i=1,(n>=3 and 2 or n>=2 and 1 or 0) do
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e9)
end
