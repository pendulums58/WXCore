-- SPK16-13B 決勝馬焼（PRカード 2020年6月～7月Ver.）
-- ベット―《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》
-- 対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。あなたがベットしていた場合、代わりに対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(4)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if not Duel.IsBet() then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if Duel.IsBet() then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=10000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
