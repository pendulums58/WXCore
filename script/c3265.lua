-- WX22-045 不幸な豆拾い　ハイカブリ
-- 【自】《ターン１回》：いずれかのプレイヤーがリフレッシュしたとき、あなたのデッキの一番上のカードをエナゾーンに置きカードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REFRESH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
