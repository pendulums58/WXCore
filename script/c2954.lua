-- WX17-073 端英の処理　＃シシゴニ＃
-- 【常】英知＝５：あなたのシグニのパワーを＋3000する。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど５であるかぎり有効になる）
-- 【常】英知＝８：あなたのシグニのパワーを＋5000する。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど８であるかぎり有効になる）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(aux.EichiCon(5))
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetCondition(aux.EichiCon(8))
  e2:SetValue(5000)
  c:RegisterEffect(e2)
end
