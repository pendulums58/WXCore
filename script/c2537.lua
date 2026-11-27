-- WX12-008 開きし者　タウィル＝トレ
-- 【自】：このカードがエクシードのコストとしてルリグトラッシュに置かれたとき、このターン、対戦相手はシグニを２体までしか場に出すことができない。（すでに場に３体ある場合は２体になるようにシグニをトラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_LTRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EXCEED~=0 end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 상대 시그니 2체까지
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SIGNI_LIMIT)
    e1:SetTargetRange(0,1)
    e1:SetValue(2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
