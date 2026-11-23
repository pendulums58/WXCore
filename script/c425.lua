-- WD02-009 羅石　ヴォルカノ
-- 【出】《赤》《赤》《赤》：対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트가 있는 【出】은 쓰지 않아도 된다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}{R}{R}")
  e1:SetTarget(s.tg(15000))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  -- 대상이 없으면 아무것도 하지 않는다(FAQ 3)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(s.tg(7000))
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
end
function s.tg(power)
  return function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetPower()<=power end,tp,0,LOCATION_SZONE,1,1,nil)
  end
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
