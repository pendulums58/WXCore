-- WX21-039 俊足の刃　#グリンブル#
-- 【自】：このシグニがアタックしたとき、あなたの場にこのシグニと共通する色を持たない他の＜天使＞のシグニがある場合、あなたのデッキの一番上のカードをエナゾーンに置く。あなたの場にそれぞれ共通の色を持たない＜天使＞のシグニが３体ある場合、代わりにあなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if (function() local seen,cnt={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):Iter() do local c=x:GetColor() local ok=c~=0 for k in pairs(seen) do if k&c~=0 then ok=false end end if ok then seen[c]=true cnt=cnt+1 end end return cnt>=3 end)() then Duel.EnaCharge(tp,2) elseif Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x~=e:GetHandler() and x:GetColor()&e:GetHandler():GetColor()==0 end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
