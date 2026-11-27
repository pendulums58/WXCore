-- WX06-020 羅植　ラフレレ
-- 【常】：このシグニのパワーは対戦相手の場にあるシグニ１体につき＋4000される。
-- 【出】：あなたの場にある【ライフバースト】を持つ他の＜植物＞のシグニ１体につきあなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：【エナチャ―ジ２】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 4000*Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end)(x) and x:IsLifeBurst() end,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()
    if n>0 then Duel.EnaCharge(tp,n) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e3)
end
