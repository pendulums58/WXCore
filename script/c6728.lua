-- WXK07-030 羅菌姫　カルシ
-- 【自】：あなたのシグニ１体がアタックしたとき、そのシグニよりパワーの低い対戦相手のシグニ１体を対象とし、《緑》《緑》《緑》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【自】《ターン１回》：あなたのパワー15000以上のシグニ１体がアタックしたとき、カードを１枚引き、【エナチャージ１】をする。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local a=eg:GetFirst()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<a:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if not tc then return end
    if not (Duel.CanPayEna(tp,"{G}{G}{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{G}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and x:GetPower()>=15000 end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
