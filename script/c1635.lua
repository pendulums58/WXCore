-- WDK07-Y07 ホワイト・シーディング
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《白×0》になる。
-- あなたの【シード】１枚を対象とし、それを開花する。そのシグニゾーンにシグニがある場合、代わりにそのシグニを手札に戻してから開花する。
-- あなたのデッキの上からカードを４枚見る。その中からカード１枚を【シード】としてあなたのシグニゾーンに出してもよい。残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_SEED,0,1,1,nil)
  end)
  -- 개화한 뒤에 【シード】를 낸다(FAQ 4)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local x=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetZone()==tc:GetZone() end,tp,LOCATION_SZONE,0,nil):GetFirst()
      if x then Duel.SendToHand(x) end
      Duel.Bloom(tc)
    end
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local sc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if sc then Duel.SetSeed(sc,tp) end
    local rest=g:Filter(function(x) return x~=sc end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
