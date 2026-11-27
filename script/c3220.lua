-- WX21-062 コードイート　ジンジャー
-- 【常】：このシグニのパワーはあなたの場にある【アクセ】１枚につき＋2000される。
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが5000以上の場合、あなたのデッキの一番上のカードをエナゾーンに置きカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 2000*Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_ACCE,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if e:GetHandler():GetPower()>=5000 then Duel.EnaCharge(tp,1) Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
