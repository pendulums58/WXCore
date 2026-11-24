-- WDK02-017 魔海の不良　マノミン
-- 【出】：各プレイヤーは手札を１枚捨てる。
-- （コストのない【出】能力は発動しないことを選べない）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 한쪽만 있어도 버린다(FAQ 1). 턴 플레이어부터
  e1:SetOperation(function(e,tp)
    local p=Duel.GetTurnPlayer()
    aux.Discard(p,1)
    aux.Discard(1-p,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
