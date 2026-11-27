-- WX10-048 参ノ遊　キセカエ
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、このシグニをバニッシュしてもよい。その後、この効果でこのシグニをバニッシュしていた場合、あなたのエナゾーンからカード１枚を対象とし、それを手札に加える。
-- ライフバースト：どちらか１つを選ぶ。①あなたのデッキの一番上のカードをエナゾーンに置く。②あなたのエナゾーンからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:GetOwner()~=tp and r&REASON_BATTLE~=0 and Duel.GetBanisher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
    if Duel.Banish(h)==0 then return end
    -- 자신도 고를 수 있다(FAQ 1)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.EnaCharge(tp,1) else local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,1,1,nil):GetFirst() if tc then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e2)
end
