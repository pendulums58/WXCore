-- WDK09-011 コードメイズ　リュウジョウ
-- 【自】：対戦相手のアタックフェイズ開始時、数字１つを宣言する。対戦相手のデッキの一番上のカードをトラッシュに置く。
--         それが宣言した数字と同じレベルのシグニの場合、カードを１枚引く。
-- 【出】《青》：【ゲート】があるシグニゾーンにある対戦相手のシグニ１体を対象とし、それをデッキの上から三番目に置く。
-- ライフバースト：手札を１枚捨てる。対象の対戦相手のシグニ１体をデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e1:SetOperation(s.decop)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetTarget(s.tg)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.lbtg)
  e3:SetOperation(s.lbop)
  c:RegisterEffect(e3)
end
function s.decop(e,tp)
  local n=Duel.AnnounceNumber(tp,0,5)
  local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
  if not top then return end
  Duel.SendToTrash(top)
  if top:IsSigni() and top:GetLevel()==n then Duel.Draw(tp,1) end
end
function s.gated(c)
  local z=c:GetZone()
  return c:IsSigni() and z~=nil and Duel.HasGate(z)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.gated,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 덱이 1장이면 맨 아래에(FAQ 1). 위 두 장은 아무도 보지 못한다(FAQ 3)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,3) end
end
function s.lbtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 손패가 0장이어도 발동하고, 버리는 부분만 아무것도 하지 않는다(FAQ 4)
function s.lbop(e,tp)
  Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_EFFECT+REASON_DISCARD)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
end
