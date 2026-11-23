-- WD04-001 四ノ娘　緑姫
-- 【常】：あなたの場に＜幻獣　セイリュ＞があり、あなたのエナゾーンにカードが７枚以上あるかぎり、あなたのシグニのパワーを＋2000する。
local s,id=GetID()
local SEIRYU=1129  -- 幻獣　セイリュ
function s.initial_effect(c)
  -- [の間] 【常】 セイリュ가 있고 에나 7장 이상인 동안. 여러 체여도 ＋2000 한 번(FAQ 1)
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
  if Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()<7 then return false end
  return Duel.GetMatchingGroup(function(x) return x:GetCode()==SEIRYU end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
end
