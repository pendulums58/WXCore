-- WD05-008 グレイブ・アウト
-- あなたのトラッシュからシグニを３枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 2장 이하여도 쓸 수 있다(FAQ 1). 대상은 코스트를 낸 뒤 고르므로 코스트로 트래시에 간 시그니도 된다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
