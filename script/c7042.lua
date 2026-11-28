-- WXK10-068 羅原　Ｃ３H８
-- 【常】：このシグニのパワーは対戦相手のセンタールリグのレベル１につき＋1000される。
-- 【自】：このシグニがアタックしたとき、このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、あなたのセンタールリグのレベルが対戦相手のセンタールリグ以下の場合、それをバニッシュする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function() return true end)
  e1:SetValue(function(e) local lc=Duel.GetMatchingGroup(nil,1-e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return 1000*(lc and lc:GetLevel() or 0) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local a=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local b=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst()
      if a and b and a:GetLevel()<=b:GetLevel() then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
