-- WDK17-012 舞踏の童話　ディンゴン
-- 【自】：対戦相手のアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【自】：ターン終了時、このシグニをバニッシュする。」を得る。
-- 【起】《ダウン》：対戦相手のトラッシュからシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。
-- （傀儡状態のシグニが場を離れる場合、代わりに持ち主のトラッシュに置かれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- [まで] ターン終了時まで 「【自】：ターン終了時、このシグニをバニッシュする。」를 얻는다
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,0))
    g:SetCode(EVENT_TURN_END)
    g:SetRange(LOCATION_SZONE)
    g:SetOperation(function(e2) local x=e2:GetHandler() if x:IsLocation(LOCATION_SZONE) then Duel.Banish(x) end end)
    g:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  -- 레벨·리미트·한정 조건은 지킨다(FAQ). 【出】은 내 쪽에 나온 것으로 발동한다
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e2)
end
