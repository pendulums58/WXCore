-- WXK10-048 羅菌　ＤＨＡ
-- 【自】《ターン２回》：あなたの＜微菌＞のシグニ１体が場に出たとき、あなたのトラッシュから＜微菌＞のシグニ１枚を対象とし、それをそのシグニの【チャーム】にする。
-- 【出】：あなたのエナゾーンからレベル３以下の＜微菌＞のシグニを１枚まで対象とし、それを手札に加える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、《緑》を支払ってもよい。そうした場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x and x:GetControler()==tp and (function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end)(x) end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    local ch=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if ch and x:IsLocation(LOCATION_SZONE) and not x:GetCharm() then Duel.Charm(ch,x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end)(y) and y:GetLevel()<=3 end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    Duel.SendToEna(tc)
  end)
  c:RegisterEffect(e9)
end
