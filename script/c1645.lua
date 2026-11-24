-- WDK08-L01 英血の器　優羽莉　Ｌｖ４
-- 【自】《ターン１回》：あなたの＜紅蓮＞のシグニ１体が血晶武装状態になったとき、カードを１枚引く。
-- 【出】《赤》：あなたのデッキの上からカードを５枚公開する。その中から＜紅蓮＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《ターン１回》《赤×0》：あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［手札］する。
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.initial_effect(c)
  -- 이미 血晶武装状態인 시그니를 다시 血晶武装해도 트리거하지 않는다(FAQ 2, 코어가 이벤트를 내지 않음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BLOOD_ARMED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and s.guren(eg:GetFirst()) end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}")
  e2:SetOperation(s.revop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetTarget(s.armtg)
  e3:SetOperation(s.armop)
  c:RegisterEffect(e3)
end
-- 덱이 4장 이하면 있는 만큼 공개한다(FAQ 3)
function s.revop(e,tp)
  local _,rest=aux.ExcavateToHand(tp,5,s.guren,0,2)
  Duel.SendToTrash(rest,REASON_EFFECT)
end
function s.armtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.guren,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.armop(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then aux.BloodArm(tp,tc,LOCATION_HAND) end
end
