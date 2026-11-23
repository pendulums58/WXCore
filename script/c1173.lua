-- WD08-013 コードアンチ　カブレラ
-- 【常】：あなたのトラッシュに＜古代兵器＞のシグニが３枚以上あるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e)
    return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KODAIHEIKI),e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=3
  end)
  e1:SetValue(8000)
  c:RegisterEffect(e1)
end
