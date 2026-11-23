-- WD05-001 獄卒の閻魔　ウリス
-- 【常】：あなたの場に《堕落の砲女　メツム》があり、あなたのトラッシュにカードが２０枚以上あるかぎり、あなたのシグニのパワーを＋2000する。
local s,id=GetID()
local METSUMU=440  -- 堕落の砲女　メツム
function s.initial_effect(c)
  -- [の間] 【常】 メツム가 있고 트래시 20장 이상인 동안. 여러 체여도 ＋2000 한 번(FAQ 1)
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
  if Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()<20 then return false end
  return Duel.GetMatchingGroup(function(x) return x:GetCode()==METSUMU end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
end
