-- WX19-046 極盾　デュエリ
-- 【常】：対戦相手のターンの間、このシグニは対戦相手のルリグとシグニの効果を受けない。
-- 【常】：対戦相手のターンの間、あなたのライフクロスはダメージ以外によってクラッシュされない。
-- 【常】：対戦相手の効果によって、あなたはダメージを受けず、あなたのライフクロスは他の領域に移動しない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋. 「ダメージ以外でクラッシュされない」·「効果でダメージを受けず、ライフクロスは移動しない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e,sc,sp) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and sp~=e:GetHandlerPlayer() and (sc:IsSigni() or sc:IsType(TYPE_LRIG)) end)
  c:RegisterEffect(e1)
end
