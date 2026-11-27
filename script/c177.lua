-- WX21-Re03 羅植　ワサビ
-- 【常】：このシグニは＜地獣＞を持つ。（場にあるかぎり有効である）
-- 【常】：あなたのエナゾーンにカードが７枚以上あるかぎり、このシグニの基本パワーは7000になる。
-- 【自】《ターン１回》：あなたのライフクロス１枚がクラッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ADD_CLASS)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(RACE_CHIJU)
  c:RegisterEffect(e1)
  aux.BasePower(c,7000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_ENA,0,nil):GetCount()>=7 end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_CRUSHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
