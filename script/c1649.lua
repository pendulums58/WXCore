-- WDK08-L06 血晶紅盾
-- あなたのシグニ１体を対象とし、ターン終了時まで、それは「【常】：バニッシュされない。」を得る。このターン、次にあなたがダメージを受ける場合、代わりにダメージを受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 시그니가 없어도 쓸 수 있고, 그때는 데미지 막기만 한다(FAQ 2). 막는 것은 다음 한 번(FAQ 1)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    -- [まで] ターン終了時まで 「【常】：バニッシュされない。」를 얻는다
    aux.GrantKeyword(e,tc,EFFECT_CANNOT_BANISH)
  end
  -- [まで] このターン. 나에게 건다
  local e2=Effect.CreateEffect(e:GetHandler())
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_PREVENT_DAMAGE)
  e2:SetTargetRange(1,0)
  e2:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e2,tp)
end
