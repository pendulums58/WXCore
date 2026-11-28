-- WXK05-009 純真の使者　サシェ
-- 【出】：このターン、対戦相手はシグニを２体までしか場に出すことができない。（すでに場に３体ある場合は２体になるように対戦相手はシグニをトラッシュに置く）
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：このターン、対戦相手のシグニがアタックしたとき、対戦相手が、このターンにシグニがアタックした回数１回につき《無》を支払わないかぎりそのシグニをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SIGNI_LIMIT)
    e1:SetTargetRange(0,1)
    e1:SetValue(2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    -- [の間] 「このターン」 어택한 횟수만큼 《無》
    local n=0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()~=tp end)
    e1:SetOperation(function(e2,tp2,eg)
      n=n+1
      local x=eg:GetFirst()
      local cost=string.rep("{C}",n)
      if Duel.CanPayEna(1-tp,cost) and Duel.SelectYesNo(1-tp) then Duel.SendToTrash(Duel.SelectEnaCost(1-tp,cost),REASON_COST) return end
      if x:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(x,REASON_EFFECT) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
