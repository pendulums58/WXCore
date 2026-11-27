-- WX14-077 コードアート　†Ｄ・Ｍ・Ｆ†
-- 【常】：あなたのトラッシュにスペルがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>0 end)
end
