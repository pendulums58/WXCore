-- WX05-040 羅植　サクラ
-- 【自】：あなたのメインフェイズの間、対戦相手のシグニ１体がバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【自】：あなたのシグニ１体が効果によってダウン状態になったとき、あなたのデッキの一番上のカードをエナゾーンに置く。（コストの支払いおよびアタックによるダウンは効果に含まれない）
-- ライフバースト：あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンからカードを１枚まで対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN and eg:GetFirst():GetOwner()~=tp end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  -- 코스트·어택으로 다운한 것은 아니다(FAQ 3). 여러 체면 각각(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DOWN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and r&REASON_COST==0 end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
