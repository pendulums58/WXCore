-- WDK08-L08 血晶魔杖
-- ベット―《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》
-- 対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。あなたがベットしていた場合、代わりに対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(4)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- ベット하면 「代わりに」라 대상을 고르지 않는다
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  if not Duel.IsBet() then
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end
end
function s.op(e,tp)
  if Duel.IsBet() then
    Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil))
    return
  end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
