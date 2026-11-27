-- WX15-039 死之遊姫　†ニホニンギョ†
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－4000する。この効果によってそのシグニのパワーが０以下になった場合、このシグニをバニッシュしてもよい。そうした場合、あなたのトラッシュから対象の＜遊具＞のシグニ１枚を場に出す。
-- 【出】：このシグニがシグニの効果によって場に出たとき、あなたのトラッシュから＜遊具＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,-4000)  -- [まで]
    local h=e:GetHandler()
    if tc:GetPower()>0 or not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.Banish(h)==0 then return end
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function(e,tp,eg,ep,ev,re) return re~=nil and re:GetHandler():IsSigni() end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
