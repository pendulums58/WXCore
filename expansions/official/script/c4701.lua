-- WXDi-D01-006 タウィル＝ハウリング
-- 【出】：対戦相手のパワー８０００以下のシグニ１体を対象とし、それをバニッシュする。カードを１枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=8000 end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end  -- 대상이 없어도 뒷부분은 처리한다(FAQ 1)
  Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  Duel.Draw(tp,1)
  Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_EFFECT+REASON_DISCARD)
end
