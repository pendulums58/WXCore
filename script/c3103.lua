-- WX20-003 クラス・クライシス
-- このアーツを使用する際、手札から＜精械＞のシグニを１枚捨ててもよい。そうした場合、このアーツの使用コストは《白×2》減る。
-- 以下の２つから２つまで選ぶ。
-- ①あなたのデッキから＜精械＞のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
-- ②対戦相手のターンの場合、ターン終了時まで、対戦相手のセンタールリグは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIKAI,0) end,tp,LOCATION_HAND,0,nil)
    local k=0
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,g,1,1)
      k=d:GetCount()
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
    end
    local c=Duel.GetUseCost()
    for _=1,k do c=Duel.ReduceCost(c,"{W}",1) c=Duel.ReduceCost(c,"{W}",1) end
    Duel.SetUseCost(c)
  end)
  e1:SetOperation(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    if m&1~=0 then local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIKAI,0) end,1):GetFirst() if x then Duel.PutOnField(x,tp,true) end aux.ShuffleDeck(tp) end
    if m&2~=0 and Duel.GetTurnPlayer()~=tp then
      local tc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
      if tc then
    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LOSE_ABILITY)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
