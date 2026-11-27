-- WX14-068 羅植　ハイビス
-- 【常】：このシグニのパワーはあなたのエナゾーンにあるカードが持つ色の種類１つにつき＋1000される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*(function(p) local n=0 for _,col in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if Duel.GetMatchingGroup(function(x) return x:IsColor(col) end,p,LOCATION_ENA,0,nil):GetCount()>0 then n=n+1 end end return n end)(e:GetHandlerPlayer()) end)
  c:RegisterEffect(e1)
end
