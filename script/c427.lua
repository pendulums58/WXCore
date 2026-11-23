-- WD02-011 羅石　ガーネット
-- 【出】：ターン終了時まで、このシグニの基本パワーは15000になる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 기본 파워 설정은 증감보다 먼저 적용된다(레이어 4·5. WXK10-054 FAQ 2)
function s.op(e,tp)
  local c=e:GetHandler()
  if not c:IsLocation(LOCATION_SZONE) then return end
  -- [まで] ターン終了時まで(FAQ 1: エンドフェイズ③)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_POWER)
  e1:SetValue(15000)
  e1:SetReset(RESET_PHASE+PHASE_END)
  c:RegisterEffect(e1)
end
