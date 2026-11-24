-- WD17-013 貫鍬の西猪　ハッカイ
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、このシグニのパワーを＋3000する。あなたの場に＜武勇＞のシグニが３体ある場合、代わりに＋5000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    local n=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_BUYU),tp,LOCATION_SZONE,0,nil):GetCount()
    aux.AddPower(e,h,n>=3 and 5000 or 3000)  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
