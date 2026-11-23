-- WD04-015 幻獣　ヒャッコ
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが3000以上である場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 정면 시그니의 파워와 상관없이 아타크하고 발동한다(FAQ 1). 파워는 처리할 때 본다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_SZONE) and c:GetPower()>=3000 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
