-- WD10-007 未来永業
-- 手札から＜ウェポン＞のシグニを２枚まで捨てる。その後、対戦相手のシグニを、この方法で捨てたシグニの枚数と同じ数だけ対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- 버리기는 코스트가 아니라 효과. 1장도 버리지 않으면 바니시하지 않는다(FAQ 1)
    local g=Duel.SelectDiscard(tp,0,2,aux.ClassFilter(0,RACE_WEAPON))
    local n=g:GetCount()
    if n==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)
    local tg=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
    if tg:GetCount()>0 then Duel.Banish(tg) end
  end)
  c:RegisterEffect(e1)
end
