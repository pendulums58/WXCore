-- WX09-057 バッド・メディスン
-- あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。その後、あなたの場に黒のシグニが３体あり、それらが共通するクラスを持つ場合、追加であなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local f=function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end
    local a=Duel.SelectTarget(tp,f,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if a then Duel.SendToHand(a) end
    if not (function() local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,nil) return g:GetCount()==3 and aux.ShareClass(g) end)() then return end
    local b=Duel.SelectTarget(tp,f,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if b then Duel.SendToHand(b) end
  end)
  c:RegisterEffect(e1)
end
