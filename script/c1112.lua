-- WD01-001 満月の巫女　タマヨリヒメ
-- 【常】：あなたの場に《甲冑　ローメイル》があるかぎり、あなたのシグニのパワーを＋2000する
local s,id=GetID()
local ROMAIL=410  -- 甲冑　ローメイル
function s.initial_effect(c)
  -- [の間] 【常】 ローメイル가 있는 동안. 여러 체여도 ＋2000 한 번(FAQ 4)
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
  local g=Duel.GetMatchingGroup(function(x) return x:GetCode()==ROMAIL end,e:GetHandlerPlayer(),LOCATION_SIGNI,0,nil)
  return g:GetCount()>0
end
