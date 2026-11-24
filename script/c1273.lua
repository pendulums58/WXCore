-- WD15-020 幻竜　サバアナ
-- 【常】：対戦相手のエナゾーンにあるカードが２枚以下であるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()<=2 end)
end
