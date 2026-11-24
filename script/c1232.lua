-- WD13-003 泡沫の巫女　タマ
-- 【常】：このカードにグロウする際、手札から＜アーム＞のシグニ１枚と＜天使＞のシグニ１枚を公開してもよい。そうした場合、このカードにグロウするためのコストは《白×1》減る。
-- 【起】《ターン１回》エクシード１：対象のあなたの白のシグニ１体を手札に戻す。対象のあなたのシグニ１体をアップする。
local s,id=GetID()
function s.initial_effect(c)
  local picked  -- 1장씩만(FAQ 1)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetMinCost(function(e,tp)
    local g=s.hand(tp)
    for x in g:Iter() do
      for y in g:Iter() do
        if s.pair(x,y) then return "{W}{W}" end
      end
    end
    return "{W}{W}{W}"
  end)
  e0:SetDeclare(function(e,tp)
    Duel.SetSelectCheck(function(g)
      local n=g:GetCount()
      if n==0 then return Duel.CanPayEna(tp,"{W}{W}{W}") end
      if n~=2 then return false end
      local it={}
      for x in g:Iter() do it[#it+1]=x end
      return s.pair(it[1],it[2]) or s.pair(it[2],it[1])
    end)
    picked=Duel.SelectCards(tp,s.hand(tp),0,2)
    Duel.SetUseCost(picked:GetCount()==2 and "{W}{W}" or "{W}{W}{W}")
  end)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked:GetCount()>0 then Duel.RevealCards(picked) end
  end)
  c:RegisterEffect(e0)
  -- 대상이 있으면 각각 반드시 고른다. 같은 시그니를 두 번 고를 수도 있다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetExceedCost(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,tp,LOCATION_SZONE,0,1,1,nil)
    e:SetLabel(g:GetCount())
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local list={}
    for tc in Duel.GetTargets():Iter() do list[#list+1]=tc end
    local i=1
    if e:GetLabel()>0 then
      if list[1]:IsRelateToEffect(e) then Duel.SendToHand(list[1]) end
      i=2
    end
    if list[i] and list[i]:IsRelateToEffect(e) then Duel.Up(list[i]) end
  end)
  c:RegisterEffect(e1)
end
function s.hand(tp)
  return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
end
function s.pair(x,y) return x~=y and x:IsClass(0,RACE_ARM) and y:IsClass(0,RACE_TENSHI) end
