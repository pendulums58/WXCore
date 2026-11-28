-- WXK06-010 ナンバー・バインド
-- このアーツの使用コストはあなたの場にあるシグニ１体につき《白×1》減る。
-- 対戦相手のシグニを、レベルの合計が６以下になるように好きな数対象とし、ターン終了時まで、それらは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetLevel() end return n<=6 end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        -- [まで] ターン終了時まで
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        x:GrantEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{W}",Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()) end)
end
