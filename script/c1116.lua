-- WD03-001 コード・ピルルク・Ｔ
-- 【常】：あなたの場に《コードアート　Ｒ・Ｍ・Ｎ》があり、対戦相手の手札が１枚以下であるかぎり、あなたのシグニのパワーを＋2000する。
local s,id=GetID()
local RMN=1119  -- コードアート　Ｒ・Ｍ・Ｎ
function s.initial_effect(c)
  -- [の間] 【常】 R・M・N이 있고 상대 패가 1장 이하인 동안. 여러 체여도 ＋2000 한 번
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
  if Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>1 then return false end
  return Duel.GetMatchingGroup(function(x) return x:GetCode()==RMN end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
end
