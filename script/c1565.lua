-- WDK06-C13 円卓の鷹掴　ガエイン
-- 【常】：あなたのトラッシュに＜武勇＞のシグニが５枚以上あるかぎり、このシグニのパワーは＋4000される。
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)  -- ＜武勇＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(s.buyu,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
end
