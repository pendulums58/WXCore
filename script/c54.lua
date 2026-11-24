-- WD14-024 デス・バイ・デス
-- 対象のあなたのシグニ１体をバニッシュする。そうした場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－8000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=tc else opp=tc end
    end
    if not (mine and mine:IsRelateToEffect(e) and Duel.Banish(mine)>0) then return end
    if opp and opp:IsRelateToEffect(e) then aux.AddPower(e,opp,-8000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
