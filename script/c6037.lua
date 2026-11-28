-- WXEX1-03 開きし者　タウィル＝フィーラ
-- 【起】《ターン１回》《白×0》：対戦相手のシグニ１体を対象とし、あなたのデッキから＜天使＞のシグニ７枚を探してトラッシュに置き、デッキをシャッフルする。この方法でカードを７枚トラッシュに置いた場合、それをトラッシュに置く。
-- 【起】《ターン１回》《アタックフェイズアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、あなたのトラッシュからそれぞれ名前の異なる＜天使＞のシグニ７枚をデッキに加えてシャッフルする。そうした場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,aux.ClassFilter(0,RACE_TENSHI),7)
    local n=0
    if g:GetCount()==7 then n=Duel.SendToTrash(g,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
    local tc=Duel.GetFirstTarget()
    if n==7 and tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_TENSHI),tp,LOCATION_TRASH,0,nil)
    local names={}
    for x in pool:Iter() do names[x:GetCode()]=true end
    local cnt=0
    for _ in pairs(names) do cnt=cnt+1 end
    if cnt<7 then return end
    Duel.SetSelectCheck(function(g)
      local seen={}
      for x in g:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return true
    end)
    local g=Duel.SelectCards(tp,pool,7,7)
    if g:GetCount()<7 then return end
    Duel.SendToDeckShuffle(g,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
