-- WXDi-D01-007 タウィル＝カラーズ
-- 【出】：あなたの場に赤のシグニがある場合、対戦相手のパワー１００００以下のシグニ１体を対象とし、それをバニッシュする。
-- 青のシグニがある場合、カードを２枚引く。緑のシグニがある場合、【エナチャージ２】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 두 색 시그니(スイギュウ 등)는 두 색 모두로 센다(FAQ 3)
function s.has(tp,col)
  for c in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    if c:IsColor(col) then return true end
  end
  return false
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=10000 end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  if s.has(tp,COLOR_RED) then Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil) end
end
-- 위에서부터 순서대로, 바꿀 수 없다(FAQ 1). 도중에 덱이 없어지면 그 뒤는 아무것도 하지 않는다(FAQ 2)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  if s.has(tp,COLOR_BLUE) then Duel.Draw(tp,2) end
  if s.has(tp,COLOR_GREEN) then Duel.EnaCharge(tp,2) end
end
