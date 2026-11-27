-- WX11-069 幻水　カンブリ
-- 【起】《アタックフェイズアイコン》このシグニを場からトラッシュに置く：カードを２枚引き、手札を１枚捨てる。（使用タイミングを持つ能力は、そのタイミングでしか使用できない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
