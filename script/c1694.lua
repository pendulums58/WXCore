-- WDK10-006 ブラッディ・ストライク
-- 対戦相手のシグニ２体を対象とし、ターン終了時まで、それらのパワーをそれぞれ－15000する。（１体のシグニだけに使用することはできない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 2체를 다 고르지 못하면 1체도 고르지 않는다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-15000) end  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
end
