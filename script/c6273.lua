-- WXK01-094 幻怪　ピスキー
-- 【常】：このシグニが中央のシグニゾーンにあるかぎり、このシグニのパワーは＋2000される。
-- 【常】：このシグニが右のシグニゾーンにあるかぎり、このシグニは対戦相手のシグニの効果によってバニッシュされない。
-- （シグニとのバトルやパワーが０以下になった場合はバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return h:IsInZone("signi_center") end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 상대 시그니 효과로 바니시되지 않는다
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_BANISH_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) local h=e:GetHandler() return h:IsInZone("signi_right") end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e2)
end
