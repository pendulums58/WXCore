-- WD08-013 コードアンチ　カブレラ
-- 【常】：あなたのトラッシュに＜古代兵器＞のシグニが３枚以上あるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e)
    return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KODAIHEIKI),e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=3
  end)
end
