-- WX22-Re05 羅菌　ニュウサ
-- 【出】：ターン終了時まで、対戦相手の感染状態のすべてのシグニのパワーを－2000する。
-- 【起】このシグニを場からトラッシュに置く：ターン終了時まで、対戦相手の感染状態のすべてのシグニのパワーを－5000する。その後、対戦相手の場にあるすべての【ウィルス】を取り除く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-2000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-5000) end  -- [まで]
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.RemoveVirus(z) end
  end)
  c:RegisterEffect(e2)
end
