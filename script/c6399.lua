-- WXK03-025 最英の探偵　ホームズ
-- 【自】：このシグニがアタックしたとき、あなたのデッキの下からカードを４枚トラッシュに置く。この方法でそれぞれレベルの異なるシグニ４枚がトラッシュに置かれた場合、対戦相手は手札を２枚捨てる。
-- 【出】：対戦相手の場にある凍結状態のシグニ１体につきカードを１枚引く。この方法で引いたカードの枚数と同じ枚数のカードを手札から好きな順番でデッキの一番下に置く。
-- ライフバースト：対戦相手のすべてのシグニを凍結する。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDeckbottomGroup(tp,4)
    local ok=false
    if g:GetCount()>0 then
      Duel.SendToTrash(g,REASON_EFFECT)
      local t=g:Filter(function(x) return x:IsSigni() and x:IsLocation(LOCATION_TRASH) end,nil)
      ok=t:GetCount()==4 and aux.DistinctLevels(t)
    end
    if ok then aux.Discard(1-tp,2) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()
    if n==0 then return end
    local before=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    Duel.Draw(tp,n)
    local k=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()-before
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    k=math.min(k,h:GetCount())
    if k>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,h,k,k)),false) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(x) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
