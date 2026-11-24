-- WDK02-008 ドント・リブミー
-- ベット―《コインアイコン》《コインアイコン》
-- 対戦相手のシグニ１体を対象とし、それをダウンする。あなたがベットしていた場合、代わりに対戦相手のシグニ２体を対象とし、それらをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 2 or 1
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
