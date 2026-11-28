-- WX20-007 ダーク・コグネイト
-- このアーツを使用する際、手札から＜精像＞のシグニを２枚まで捨ててもよい。このアーツの使用コストは、この方法で捨てたシグニ１枚につき《黒×1》《無×1》減る。
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
-- ③あなたのトラッシュから＜精像＞のシグニ１枚を対象とし、それを場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base)
    local k=math.min(2,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIZOU,0) end,tp,LOCATION_HAND,0,nil):GetCount())
    for _=1,k do base=Duel.ReduceCost(base,"{B}",1) base=Duel.ReduceCost(base,"{C}",1) end
    return base
  end)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIZOU,0) end,tp,LOCATION_HAND,0,nil)
    local k=0
    if g:GetCount()>0 and (not Duel.CanPayEna(tp,Duel.GetUseCost()) or Duel.SelectYesNo(tp)) then
      local d=Duel.SelectCards(tp,g,1,2)
      k=d:GetCount()
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
    end
    local cost=Duel.GetUseCost()
    for _=1,k do cost=Duel.ReduceCost(cost,"{B}",1) cost=Duel.ReduceCost(cost,"{C}",1) end
    Duel.SetUseCost(cost)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t1=m&1~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
    s.t2=m&2~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
    s.t3=m&4~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIZOU,0) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if s.t1 and s.t1:IsRelateToEffect(e) then Duel.Banish(s.t1) end
    if s.t2 and s.t2:IsRelateToEffect(e) then aux.AddPower(e,s.t2,-12000) end  -- [まで]
    if s.t3 and s.t3:IsRelateToEffect(e) then Duel.PutOnField(s.t3,tp,true) end
  end)
  c:RegisterEffect(e1)
end
