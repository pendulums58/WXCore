-- PR-366 験英の応援　＃ゴウカク＃（ウィクロスマガジンvol6 付録）
-- 【出】英知=５：あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【自】英知=８：このシグニがアタックしたとき、対戦相手のレベル３以下のシグニ１体を対象とし、それをエナゾーンに置く。
-- 【自】英知=１０：このシグニがアタックしたとき、あなたの他のシグニ１体を対象とし、それの【自】の【英知】能力１つを発動させる。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(5))
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.EichiCon(8))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetCondition(aux.EichiCon(10))
  -- 다른 시그니의 【自】【英知】 능력 하나를 조건을 채운 것으로 발동한다(식이 맞지 않아도 된다. FAQ 4·5)
  e3:SetOperation(function(e,tp)
    -- 그 시그니의 인쇄된 【自】 중 하나(＜英知＞의 【自】는 【英知】 능력으로 근사)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and #x:GetTriggerDescs()>0 end,tp,LOCATION_SZONE,0,1,1,e:GetHandler()):GetFirst()
    if not tc then return end
    local list=tc:GetTriggerDescs()
    local i=#list==1 and 1 or Duel.SelectOption(tp,table.unpack(list))+1
    Duel.FireTrigger(tc,list[i])
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e4)
end
