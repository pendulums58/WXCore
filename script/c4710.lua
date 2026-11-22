-- WXDi-D01-017 翠天　アタランテ
-- 【出】エナゾーンからそれぞれ異なるクラスを持つシグニ３枚をトラッシュに置く：対戦相手のパワー８０００以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(s.cost)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 에나의 시그니 중에 서로 다른 클래스를 맞출 수 있는 3장이 있는가(FAQ 2)
function s.has3(g)
  local n=g:GetCount()
  for i=1,n-2 do
    for j=i+1,n-1 do
      for k=j+1,n do
        if aux.DistinctClasses(Group.CreateGroup(g[i],g[j],g[k])) then return true end
      end
    end
  end
  return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil)
  if chk==0 then return s.has3(g) end
  Duel.SetSelectCheck(aux.DistinctClasses)
  Duel.SendToTrash(Duel.SelectCards(tp,g,3,3),REASON_COST)
end
function s.filter(c) return c:IsSigni() and c:GetPower()>=8000 end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
