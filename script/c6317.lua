-- WXK02-041 讃の遊　オエカキボード
-- 【常】：あなたの＜遊具＞のシグニのパワーを＋1000する。
-- 【自】：シグニ１体が場から手札に戻ったとき、あなたの＜遊具＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_HAND)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) for x in eg:Iter() do if x:IsType(TYPE_SIGNI) and x:IsPreviousLocation(LOCATION_SZONE) then return true end end return false end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,2000)
    end
  end)
  c:RegisterEffect(e2)
end
