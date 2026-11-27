-- WX13-003 アイスフレイム・シュート
-- 以下から４つから４つまで選ぶ。選んだ数が３つ以上の場合、このアーツの使用コストは、選んだ数から２を引いた数だけ《無×2》増える。
-- ①対戦相手のセンタールリグ１体を対象とし、それをダウンする。
-- ②対戦相手のセンタールリグ１体を対象とし、それを凍結する。
-- ③対戦相手のパワー７０００以下のシグニ１体を対象とし、それをバニッシュする。
-- ④レゾナではない対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたは手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m,n=0,0
    for _,i in ipairs(Duel.SelectModes(tp,1,4,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) n=n+1 end
    e:SetLabel(m)
    -- 3개 이상이면 (수−2)×《無》×2 늘어난다
    if n>=3 then Duel.SetUseCost(Duel.GetUseCost()..string.rep("{C}",2*(n-2))) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.l=(m&3~=0) and Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() or nil
    s.a=m&4~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
    s.b=m&8~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if s.l and s.l:IsRelateToEffect(e) then
      if m&1~=0 then Duel.Down(s.l) end
      if m&2~=0 then Duel.Freeze(s.l) end
    end
    if s.a and s.a:IsRelateToEffect(e) then Duel.Banish(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then Duel.Banish(s.b) aux.Discard(tp,1) end
  end)
  c:RegisterEffect(e1)
end
