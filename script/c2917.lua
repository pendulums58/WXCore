-- WX17-028 羅星姫　≡ソラフレア≡
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュからそれぞれレベルの異なる＜宇宙＞のシグニ４枚をデッキに戻してシャッフルしてもよい。そうした場合、ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- 【出】《赤×0》:あなたのデッキの上からカードを４枚公開する。その後、パワーが「この方法で公開したシグニのレベルの合計×1000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。公開したカードをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜宇宙＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
    local pick=Duel.SelectCards(tp,g,0,4)
    local ok=pick:GetCount()==4
    if ok then Duel.SendToDeckShuffle(pick,tp) end
    local h=e:GetHandler()
    if ok and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local sum=0
    for x in g:Iter() do if x:IsSigni() then sum=sum+x:GetLevel() end end
    local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetPower()<=sum*1000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
