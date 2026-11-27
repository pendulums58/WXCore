-- WX17-061 羅星　≡ブンテン≡
-- 【常】：このカードがデッキか手札かトラッシュにあるかぎり、あなたの能力か効果１つによってこのシグニのレベルを参照する場合、１～３いずれかのレベル１つとして扱ってもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「１～３」은 1~4로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ANY_LEVEL)
  e1:SetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_TRASH)
  c:RegisterEffect(e1)
end
