-- WD01-008 バロック・ディフェンス
-- 対戦相手のセンタールリグかシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG+LOCATION_SIGNI,1,1,nil)
end
-- 능력을 얻는 것이라 룰을 바꾸는 효과가 아니다(FAQ 2)
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
