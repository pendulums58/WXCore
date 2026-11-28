-- WXK07-027 羅原姫　An
-- 【常】：あなたのターンの間、あなたのトラッシュに＜原子＞のシグニが７枚以上あるかぎり、このシグニのパワーは＋7000される。
-- 【自】《ターン１回》：このシグニが対戦相手のシグニ１体をバニッシュしたとき、《赤》を支払ってもよい。その後、この方法で《赤》を支払った場合、このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=7 end)
  e1:SetValue(7000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=h:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
