-- WX13-084 幻竜　＃キノボリ＃
-- 【常】：あなたのエナゾーンにあるカードが持つ色が２種類以上あるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) local n=0 for _,col in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if Duel.GetMatchingGroup(function(x) return x:IsColor(col) end,e:GetHandlerPlayer(),LOCATION_ENA,0,nil):GetCount()>0 then n=n+1 end end return n>=2 end)
end
