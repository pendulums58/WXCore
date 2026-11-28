-- WXK04-072 紅蓮の使い魔　ママリリ
-- 【常】：このシグニが血晶武装状態であるかぎり、このシグニのパワーは＋3000され、このシグニは、このシグニの正面以外の対戦相手のシグニゾーンにもアタックできる。（シグニゾーンへのアタックでは対戦相手にダメージを与えない）
-- 【起】《ダウン》：このシグニの正面のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_ATTACK_ZONE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(aux.SelfDownCost)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local f=e:GetHandler():GetFrontCard()
    Duel.SelectTarget(tp,function(x) return x==f and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if tc:GetPower()<=3000 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
