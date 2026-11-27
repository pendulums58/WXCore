-- WX01-002 暁の巫女　タマヨリヒメ
-- 【常】：あなたの場に白と赤のシグニがあるかぎり、あなたのシグニのパワーを＋3000する。
-- 【出】：対戦相手のパワー10000以下のシグニ１体を対象とし、それをトラッシュに置く。
-- 【起】《白》《白》《赤》《ダウン》：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,p,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,p,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(aux.BanishPowerTarget(10000))
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetEnaCost("{W}{W}{R}")
  e3:SetCost(aux.SelfDownCost)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
