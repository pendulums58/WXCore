-- WX21-023 幻竜　ゲツァル
-- 【自】：このシグニがアタックしたとき、あなたの手札からそれぞれ名前が異なる＜龍獣＞のシグニを４枚まで公開する。その後、この方法でシグニを２枚以上公開した場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ３枚以上の場合、対戦相手は自分のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。
-- ４枚の場合、ターン終了時まで、このシグニは【アサシン】を得る。
-- ライフバースト：あなたのデッキの上からカードを３枚公開する。その中から＜龍獣＞のシグニ１枚を手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_HAND,0,nil)
    Duel.SetSelectCheck(function(sg) local seen={} for x in sg:Iter() do if seen[x:GetCode()] then return false end seen[x:GetCode()]=true end return true end)
    local r=Duel.SelectCards(tp,g,0,4)
    local n=r:GetCount()
    if n>0 then Duel.RevealCards(r) end
    if n>=2 then Duel.EnaCharge(tp,1) end
    if n>=3 then local x=Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil):GetFirst() if x then Duel.SendToTrash(x,REASON_EFFECT) end end
    local h=e:GetHandler()
    if n>=4 and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_ASSASSIN) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
