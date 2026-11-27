-- WX17-059 羅星　≡コウドウ≡
-- 【常】：このカードがデッキか手札かトラッシュにあるかぎり、あなたの能力か効果１つによってこのシグニのレベルを参照する場合、１～４いずれかのレベル１つとして扱ってもよい。
-- （実際のレベルは変わらない。例えば効果によってレベル１のシグニとして場に出そうとしてもセンタールリグのレベルが１の場合、場に出すことはできない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ANY_LEVEL)
  e1:SetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_TRASH)
  c:RegisterEffect(e1)
end
