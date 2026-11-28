-- WXK04-037 羅植　カスミソウ
-- 【常】：あなたの＜植物＞のシグニのパワーを＋1000する。
-- 【自】《ターン１回》：あなたのエナゾーンにカード１枚が置かれたとき、あなたの＜植物＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋4000する。（このシグニが場からエナゾーンに置かれたときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 이 시그니가 에나에 갔을 때도(카드 주석)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_ENA)
  e2:SetRange(LOCATION_SZONE+LOCATION_ENA)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) for x in eg:Iter() do if x:GetOwner()==tp then return true end end return false end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,4000)
    end
  end)
  c:RegisterEffect(e2)
end
