-- WXK07-037 羅原　Nig
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：あなたがアーツを使用したとき、ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。」を得る。
-- （【ダブルクラッシュ】を持つシグニがアタックによってダメージを与えた場合ライフクロスを１枚ではなく２枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_USE_CARD)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  g:SetOperation(function(e,tp) local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
