-- WD02-001 花代・肆
-- 【常】：あなたのターンの間、あなたの場に《羅石　ヴォルカノ》があるかぎり、あなたのシグニのパワーを＋2000する。
local s,id=GetID()
local VOLCANO=425  -- 羅石　ヴォルカノ
function s.initial_effect(c)
  -- [の間] 【常】 내 턴이고 ヴォルカノ가 있는 동안. 여러 체여도 ＋2000 한 번(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetValue(2000)
  e1:SetCondition(s.con)
  c:RegisterEffect(e1)
end
function s.con(e)
  local tp=e:GetHandlerPlayer()
  if Duel.GetTurnPlayer()~=tp then return false end
  return Duel.GetMatchingGroup(function(x) return x:GetCode()==VOLCANO end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
end
