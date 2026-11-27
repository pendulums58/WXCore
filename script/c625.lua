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
  e1:SetDeclare(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIZOU,0) end,tp,LOCATION_HAND,0,nil)
    local k=0
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,g,1,2)
      k=d:GetCount()
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
    end
    local c=Duel.GetUseCost()
    for _=1,k do c=Duel.ReduceCost(c,"{B}",1) c=Duel.ReduceCost(c,"{C}",1) end
    Duel.SetUseCost(c)
  end)
  e1:SetOperation(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    if m&1~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&2~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then aux.AddPower(e,tc,-12000) end end
    if m&4~=0 then local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIZOU,0) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.PutOnField(x,tp,true) end end
  end)
  c:RegisterEffect(e1)
end
