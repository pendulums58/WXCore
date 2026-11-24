-- WD20-006 全知全能
-- ベット―《コインアイコン》《コインアイコン》
-- 対戦相手のシグニ２体と、エナゾーンにあるカード２枚を対象とし、それらをトラッシュに置く。その後、対戦相手は手札を２枚捨てる。あなたのデッキの一番上のカードをライフクロスに加える。このターンが対戦相手のターンで、あなたがベットしていなかった場合、次のあなたのターンをスキップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  -- 2체(2장)를 다 대상으로 할 수 없으면 하나도 대상으로 하지 않는다(FAQ 3·4)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetCount()>=2 then
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
    end
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()>=2 then
      Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,2,2,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    aux.Discard(1-tp,2)
    Duel.SendToLife(Duel.GetDecktopGroup(tp,1))
    if Duel.GetTurnPlayer()~=tp and not Duel.IsBet() then Duel.SkipTurn(tp) end
  end)
  c:RegisterEffect(e1)
end
