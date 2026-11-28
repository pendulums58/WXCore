-- WXK09-023 空走経路
-- あなたのエナゾーンから＜電機＞のシグニを、パワーの合計が12000になるように３枚まで対象とし、それらを場に出す。それらの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetPower() end return sg:GetCount()==0 or n==12000 end)
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_ENA,0,0,3,nil)
    for x in g:Iter() do Duel.PutOnField(x,tp,true) end
  end)
  c:RegisterEffect(e1)
end
