-- WX02-027 焦土の代償
-- あなたの＜アーム＞か＜ウェポン＞のシグニを好きな数対象とし、それらをトラッシュに置く。その後、この方法でトラッシュに置いたシグニ１体につき対戦相手のシグニ１体を対象とし、それらをバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  -- 놓은 수만큼 처리할 때 고른다(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==0 then return end
    local n=Duel.SendToTrash(g,REASON_EFFECT)
    local m=math.min(n,Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetCount())
    if m==0 then return end
    local tg=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,m,m,nil)
    if tg:GetCount()>0 then Duel.Banish(tg) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 패가 없어도 바니시한다(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
end
