-- WXDi-D01-015 大装　トビエル
-- 【自】：このシグニがアタックしたとき、あなたの他のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋５０００する。
-- 【出】手札を２枚捨てる：カードを２枚引く。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のアップ状態のシグニ１体を対象とし、それをバニッシュする。②カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(s.atg)
  e1:SetOperation(s.aop)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(s.cost)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.lbtg)
  e3:SetOperation(s.lbop)
  c:RegisterEffect(e3)
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
end
function s.aop(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetValue(5000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end
-- 손패가 1장이면 1장도 버릴 수 없고 발동하지 않는다(FAQ 1)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=2 end
  Duel.SendToTrash(Duel.SelectDiscard(tp,2,2),REASON_COST+REASON_DISCARD)
end
function s.upfilter(c) return c:IsSigni() and c:IsUp() end
function s.lbtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local op=Duel.SelectOption(tp,"banish","draw")
  e:SetLabel(op)
  if op==0 then Duel.SelectTarget(tp,s.upfilter,tp,0,LOCATION_SZONE,1,1,nil) end
end
function s.lbop(e,tp)
  if e:GetLabel()==0 then
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  else
    Duel.Draw(tp,1)
  end
end
