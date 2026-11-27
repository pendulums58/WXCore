-- WX15-005 火竜点睛
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのデッキから《ライズアイコン》を持つシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。その後、場に出したシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたがベットしていた場合、代わりに場に出したシグニのパワー以下の対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,1):GetFirst()
    local p=nil
    if x and Duel.PutOnField(x,tp,true) and x:IsLocation(LOCATION_SZONE) then p=x:GetPower() end
    aux.ShuffleDeck(tp)
    if not p then return end
    if Duel.IsBet() then
      local g=Duel.GetMatchingGroup(function(c) return c:IsSigni() and c:GetPower()<=p end,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
    else
      local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
