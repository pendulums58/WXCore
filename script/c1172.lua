-- WD08-012 コードアンチ　アステカ
-- 【出】：あなたのトラッシュからレベル１の＜古代兵器＞のシグニ１枚を対象とし、それを場に出す。ターン終了時、それを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) and x:GetLevel()==1 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e) and Duel.PutOnField(tc,tp)) then return end
  -- 그 객체에 건다. 장을 떠나면 새 객체라 끊긴다(FAQ 1)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetReset(RESET_PHASE+PHASE_END)
  e1:SetOperation(function(e1)
    local h=e1:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  tc:RegisterEffect(e1)
end
