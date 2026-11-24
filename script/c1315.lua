-- WD20-015 具英の距測　＃ジョウギ＃
-- 【常】英知=２：このシグニのパワーは＋3000される。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど２であるかぎり有効になる）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(aux.EichiCon(2))
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
