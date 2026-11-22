-- WDK-F03-14 讃の遊　ユキガッセン
-- 【出】：対戦相手のレベル３以下のシグニ１体を対象とし、あなたのターンにこのシグニがデッキから場に出た場合、それを手札に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
function s.lv3(c) return c:IsSigni() and c:GetLevel()<=3 end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.lv3,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local c=e:GetHandler()
  if Duel.GetTurnPlayer()~=tp or not c:IsPreviousLocation(LOCATION_MDECK) then return end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
