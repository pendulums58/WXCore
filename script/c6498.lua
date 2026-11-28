-- WXK04-042 紅蓮の使い魔　オトタチバナ
-- 【常】：このシグニが血晶武装状態であるかぎり、このシグニのパワーは＋2000され、このシグニは「【自】：このシグニがアタックしたとき、このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが10000以上の場合、対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local pw=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_GRANT)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  e2:SetLabelObject(g)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if e:GetHandler():GetPower()>=10000 and tc:GetPower()<=7000 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
