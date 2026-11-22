-- WXDi-D01-021 複成
-- あなたのエナゾーンから緑のシグニ１枚を対象とし、それを手札に加える。
-- あなたの場に＜アンシエント・サプライズ＞のルリグが３体いる場合、代わりにあなたのエナゾーンからシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：対戦相手のアップ状態のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(s.lbtg)
  e2:SetOperation(s.lbop)
  c:RegisterEffect(e2)
end
function s.green(c) return c:IsSigni() and c:IsColor(COLOR_GREEN) end
-- 코스트로 낸 에나는 이미 트래시라 고를 수 없다(FAQ 1)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local f=Duel.IsTeam(tp,"アンシエント・サプライズ") and Card.IsSigni or s.green
  Duel.SelectTarget(tp,f,tp,LOCATION_ENA,0,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
function s.upfilter(c) return c:IsSigni() and c:IsUp() end
function s.lbtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.upfilter,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.lbop(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
