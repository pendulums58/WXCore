-- SP27-012 悲劇の予言　§テティス§（セレクターズパック vol.18）
-- 【自】：このシグニがアタックしたとき、あなたの場にこのシグニと共通する色を持たない他の＜天使＞のシグニがある場合、カードを１枚引く。あなたの場にそれぞれ共通する色を持たない＜天使＞のシグニが３体ある場合、代わりにカードを２枚引く。
local s,id=GetID()
function s.angel(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end
-- 서로 공통된 색이 없는가(FAQ 1: 세 체 모두가 서로)
function s.apart(a,b) return a:GetColor()&b:GetColor()==0 end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.angel,tp,LOCATION_SZONE,0,nil)
    local t={}
    for x in g:Iter() do t[#t+1]=x end
    if #t==3 and s.apart(t[1],t[2]) and s.apart(t[1],t[3]) and s.apart(t[2],t[3]) then Duel.Draw(tp,2) return end
    for x in g:Iter() do
      if x~=h and s.apart(x,h) then Duel.Draw(tp,1) return end
    end
  end)
  c:RegisterEffect(e1)
end
