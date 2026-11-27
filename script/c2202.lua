-- WX07-033 羅星　アルファード
-- 【常】：あなたは、自分でこのシグニを場からトラッシュに置くことができない。
-- 【自】：あなたのシグニ１体がバニッシュされたとき、このシグニをバニッシュしてもよい。そうした場合、バニッシュされた《羅星　アルファード》ではないそのシグニをエナゾーンから場に出す。
-- 【自】：あなたのレゾナ１体が場に出たとき、《白》を支払ってもよい。そうした場合、このシグニをトラッシュからダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 리무브·자기 코스트·효과·출현 조건(FAQ 1). 룰 처리는 된다(FAQ 2·3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_SELF_TRASH)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_SZONE) and x~=e:GetHandler() end)
  e2:SetOperation(function(e,tp,eg)
    local h,x=e:GetHandler(),eg:GetFirst()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
    if Duel.Banish(h)==0 then return end
    -- 《羅星　アルファード》는 되돌리지 않는다(FAQ 5)
    if x:IsLocation(LOCATION_ENA) and not x:IsCardName(id) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
  -- 트래시에서. 에나의 자신으로 낼 수는 없다(FAQ 6)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetRange(LOCATION_TRASH)
  e3:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_RESONA) end)
  e3:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.PutOnField(h,tp) then Duel.Down(h) end
  end)
  c:RegisterEffect(e3)
end
