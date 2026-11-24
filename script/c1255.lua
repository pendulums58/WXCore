-- WD14-015 三途の往復　アザゼラ
-- 【自】：このシグニが効果によって場からトラッシュに置かれたとき、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트·출현 조건은 효과가 아니다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and (r&REASON_EFFECT)~=0
  end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
