-- WX14-CB01 燦
-- 【常】：あなたの＜ウェポン＞のシグニは対戦相手のシグニの効果を受けない。
-- 【自】：このシグニが効果によってダウン状態になったとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【出】《白》：あなたのデッキから《暁月》１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DOWN)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_COST==0 end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{W}")
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsCardName(2740) end,1)
  end)
  c:RegisterEffect(e3)
end
