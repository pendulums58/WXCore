-- WDK12-011 羅菌 ヨウサン
-- 【常】：【チャーム】が付いているあなたのシグニのパワーを＋3000する。
-- 【起】《ターン１回》《緑×0》：ターン終了時まで、【チャーム】が付いているあなたのすべてのシグニは【ランサー】を得る。
-- ライフバースト：対戦相手のパワー8000以上のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:GetCharm()~=nil end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  -- 【チャーム】이 떨어져도 그 턴은 【ランサー】를 가진다(FAQ 1)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,nil):Iter() do aux.GrantKeyword(e,tc,EFFECT_LANCER) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e3)
end
