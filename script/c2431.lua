-- WX10-063 爆砲　ナポレホウ
-- 【常】：あなたのセンタールリグが赤で、このシグニが中央のシグニゾーンにあるかぎり、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のパワー1000以下のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(aux.BanishPowerTarget(1000))
  g:SetOperation(aux.BanishOp)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x)
    if x~=e:GetHandler() or not x:IsInZone("signi_center") then return false end
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return lc and lc:IsColor(COLOR_RED)
  end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
