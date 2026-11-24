-- WDK01-011 コードライド　ヤマテ
-- 【ドライブ常】：このシグニのパワーは＋3000され、このシグニは「【自】：このシグニがアタックしたとき、自身のパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【ドライブ常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsDrive() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local pw=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  -- [の間] 【ドライブ常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_GRANT)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler() and x:IsDrive() end)
  e2:SetLabelObject(g)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(aux.BanishPowerTarget(12000))
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
end
