-- WDK-F03-09 燃盛　遊月・鍵 (キー)
-- 【常】：あなたのセンタールリグは以下の能力を得る。
--   【起】エクシード１：このターン、対戦相手はレベル１のシグニで【ガード】ができない。
-- 【出】：対戦相手のエナゾーンから無色のカードを２枚まで対象とし、それらをトラッシュに置く。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,0))
  g:SetRange(LOCATION_LRIG)
  g:SetExceedCost(1)
  g:SetOperation(s.guardop)
  -- [の間] 【常】 센터 루리그가 얻는다. 루리그가 그로우해도 키는 남고 효과도 계속된다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_LRIG,0)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(s.enatg)
  e2:SetOperation(s.enaop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(s.keycost)
  e3:SetTarget(s.onetg)
  e3:SetOperation(s.enaop)
  c:RegisterEffect(e3)
end
function s.guardop(e,tp)
  -- [まで] このターン. 상대 플레이어에 건다
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CANNOT_GUARD)
  e1:SetTargetRange(0,1)
  e1:SetValue(1)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
end
function s.colorless(c) return c:GetColor()==0 end
-- 「２枚まで」: 0~2장(FAQ 3)
function s.enatg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.colorless,tp,0,LOCATION_ENA,0,2,nil)
end
function s.enaop(e,tp)
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then Duel.SendToTrash(tc) end
  end
end
function s.keycost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
  Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
end
function s.onetg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ENA,1,nil) end
  Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
end
