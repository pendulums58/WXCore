-- WX18-004 ドント・アクト
-- ベット―《コインアイコン》《コインアイコン》《コインアイコン》
-- 対戦相手のシグニ１体を対象とし、それをダウンし、カードを１枚引く。あなたがベットしていた場合、代わりに対戦相手のシグニ３体を対象とし、それらをダウンし、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(3)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 3 or 1
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
  end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Down(x) end end
    Duel.Draw(tp,Duel.IsBet() and 3 or 1)
  end)
  c:RegisterEffect(e1)
end
