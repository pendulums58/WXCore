-- WXK10-064 大装　ヒゲキリ
-- 【常】：このシグニのパワーはあなたの場にある《ライズアイコン》を持つシグニ１体につき＋2000される。
-- 【出】手札から＜アーム＞のシグニを１枚捨てる：このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function() return true end)
  e1:SetValue(function(e) return 2000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e2)
end
