-- WD07-004 クレセント/メイデン　イオナ
-- 【常】：対戦相手のシグニは可能ならばアタックしなければならない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 시그니 어택 스텝에 어택할 수 있는지만 본다. 다운된 시그니는 안 해도 된다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SIGNI)
  c:RegisterEffect(e1)
end
