-- WXK03-011 レイラ＝クレジット
-- 【常】：あなたは対戦相手の効果によってダメージを受けず、シグニゾーン以外のあなたの領域にあるカードは、対戦相手の効果によってトラッシュとデッキに移動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 효과 대미지만. 어택·【アサシン】은 아니다(FAQ 1·11). 「トラッシュとデッキに移動しない」는 아직
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_DAMAGE)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(1,0)
  e1:SetValue(1)
  c:RegisterEffect(e1)
end
