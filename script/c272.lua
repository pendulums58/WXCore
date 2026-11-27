-- WX20-036-CB 温泉の盛宴　草津結衣奈
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【常】：あなたの他のシグニはライフバーストではない対戦相手のシグニの効果を受けず、それらのパワーを＋3000する。」を得る。
-- 【自】：このシグニがバニッシュされたとき、《赤》《赤》を支払ってもよい。そうした場合、このシグニをエナゾーンからダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 중앙에 있는 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() end)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetValue(function(e,sc,sp,burst) return sp~=e:GetHandlerPlayer() and sc:IsSigni() and not burst end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x~=e:GetHandler() end)
  e2:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e2:SetValue(3000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_BANISHED)
  e3:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
      local h=e:GetHandler() if h:IsLocation(LOCATION_ENA) then Duel.PutOnField(h,tp,false,true) end
    end
  end)
  c:RegisterEffect(e3)
end
