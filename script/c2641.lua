-- WX13-070 羅石　アンチモン
-- 【起】《赤》このシグニを場からトラッシュに置く：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{R}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
