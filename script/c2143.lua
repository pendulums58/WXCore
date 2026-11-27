-- WX06-022 大槍　トライデ
-- 【常】：あなたのセンタールリグが白で、このシグニが中央のシグニゾーンにあるかぎり、このシグニの基本パワーは10000になり、このシグニは「【常】：このシグニは対戦相手の効果によってバニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘. 파워 0 이하 룰 바니시는 막지 않는다(FAQ 2)
  aux.BasePower(c,10000,function(e) local h=e:GetHandler() if not h:IsInZone("signi_center") then return false end local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_WHITE) end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_BANISH_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) local h=e:GetHandler() if not h:IsInZone("signi_center") then return false end local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_WHITE) end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e2)
end
