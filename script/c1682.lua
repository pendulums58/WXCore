-- WDK09-009 眩しき者　タウィル (キー)
-- 【常】：あなたのセンタールリグは以下の能力を得る。
--   【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- 【常】：対戦相手の手札の上限は１減る。
-- 【出】：あなたのセンタールリグが＜ウムル＞の場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetRange(LOCATION_LRIG)
  g:SetTiming(TIMING_ATTACK)
  g:SetExceedCost(2)
  g:SetTarget(s.tg)
  g:SetOperation(s.op)
  -- [の間] 【常】 센터 루리그가 얻는다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_LRIG,0)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  -- [の間] 【常】 상대 손패 상한 -1(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_HAND_LIMIT)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(0,1)
  e2:SetValue(-1)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(s.drawop)
  c:RegisterEffect(e3)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(e1)
  end
end
-- 루리그 타입이 タウィル이면서 ウムル인 센터도 된다(FAQ 3)
function s.drawop(e,tp)
  local center=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  if center and center:IsClass("ウムル") then Duel.Draw(tp,1) end
end
