-- WX22-037 伝達の朱鷺　§ヘルメス§
-- 【出】：あなたの手札からそれぞれ異なる色を持つ＜天使＞のシグニを好きな枚数捨てる。この方法で捨てたシグニ１枚につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
    Duel.SetSelectCheck(function(sg) local m=0 for x in sg:Iter() do if x:GetColor()&m~=0 then return false end m=m|x:GetColor() end return true end)
    local d=Duel.SelectCards(tp,g,0,5)
    local n=d:GetCount()>0 and Duel.SendToTrash(d,REASON_EFFECT+REASON_DISCARD) or 0
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e1)
end
