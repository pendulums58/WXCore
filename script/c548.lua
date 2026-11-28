-- SP27-003 惨之遊　†バカラ†（セレクターズパック vol.15）
-- 【自】：アタックフェイズの間、このシグニがあなたの効果によって場からトラッシュに置かれたとき、あなたのトラッシュから《惨之遊　†バカラ†》以外のレベル３以下の＜遊具＞のシグニ１枚を対象とし、それをダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  -- 내 효과로 장에서(룰 처리·출현 조건은 아니다, FAQ 1). 바니시가 트래시로 바뀐 것도(FAQ 2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetPhase()==PHASE_ATTACK and e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and rp==tp and r&REASON_EFFECT~=0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) and x:GetLevel()<=3 and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp,false,true) end
  end)
  c:RegisterEffect(e1)
end
