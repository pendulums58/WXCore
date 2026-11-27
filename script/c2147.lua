-- WX06-026 羅石　カクセン
-- 【常】：あなたのセンタールリグが赤で、このシグニが中央のシグニゾーンにあるかぎり、このシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() if not h:IsInZone("signi_center") then return false end local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_RED) end)
  c:RegisterEffect(e1)
end
