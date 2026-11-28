-- WXK04-023 虎視眈眈
-- 対象の対戦相手のシグニ１体をエナゾーンに置く。ターン終了時まで、対象のあなたのシグニ１体のパワーを＋10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:GetControler()~=tp then Duel.SendToEna(x) else aux.AddPower(e,x,10000) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
