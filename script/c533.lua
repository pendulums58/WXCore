-- WD18-011 コードイート　カレー
-- 【常】：このシグニがアクセされているかぎり、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 アクセされている 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsAcce() end)
  c:RegisterEffect(e1)
end
