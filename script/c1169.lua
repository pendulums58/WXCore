-- WD08-009 コードアンチ　ネッシー
-- 【自】：あなたのトラッシュからシグニ１体が場に出たとき、対戦相手のシグニ１体を対象とし、《黒》《黒》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【起】《黒》《黒》《無》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。このカードをトラッシュからデッキの一番下に置く。
--   （この能力はこのカードがトラッシュにある場合にしか使用できない）
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを-10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 이 시그니 자신이 트래시에서 나와도 트리거(FAQ 2). 1체에 한 번만 낸다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg)
    local x=eg:GetFirst()
    return x and x:IsSigni() and x:GetControler()==tp and x:IsPreviousLocation(LOCATION_TRASH)
  end)
  e1:SetTarget(s.opptg)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and Duel.CanPayEna(tp,"{B}{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}{B}"),REASON_COST)
    if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  -- 한정 조건과 관계없이 쓸 수 있다(FAQ 4)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetEnaCost("{B}{B}{C}")
  e2:SetTarget(s.opptg)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end  -- [まで] ターン終了時まで
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_TRASH) then Duel.SendToDeckBottom(c,false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.opptg)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
end
function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
