-- WX15-068 四郡の南王　モウカク
-- 【起】《ダウン》エナゾーンから＜武勇＞のシグニ１枚をトラッシュに置く：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ダウン》：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。この能力はあなたの場に《ライズアイコン》を持つシグニがある場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetTarget(aux.BanishPowerTarget(10000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetTarget(aux.BanishPowerTarget(12000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
