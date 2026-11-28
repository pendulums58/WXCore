-- WXK10-084 大罠　キノコイモムシ
-- 【自】：レベルが奇数のあなたの＜トリック＞のシグニ１体がアタックしたとき、レベルが偶数の対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをアタックしたそのシグニのレベル１につき－1000する。
-- 【自】：レベルが偶数のあなたの＜トリック＞のシグニ１体がアタックしたとき、レベルが奇数の対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをアタックしたそのシグニのレベル１につき－1000する。
-- 【起】《ターン１回》《黒×0》：ターン終了時まで、このシグニのレベルを－１する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and x:IsClass(0,RACE_TRICK) and x:GetLevel()%2==1 end)
  e1:SetOperation(function(e,tp,eg)
    local a=eg:GetFirst()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()%2==0 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-1000*a:GetLevel()) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and x:IsClass(0,RACE_TRICK) and x:GetLevel()%2==0 end)
  e2:SetOperation(function(e,tp,eg)
    local a=eg:GetFirst()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()%2==1 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-1000*a:GetLevel()) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_LEVEL)
      e1:SetValue(-1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      h:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e3)
end
