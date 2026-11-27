-- WX16-022 香美脆味
-- あなたのエナゾーンから対象の好きな枚数の《アクセアイコン》を持つシグニを、対象のあなたの好きな数のシグニの【アクセ】にする。
-- （【アクセ】にするためのコストは支払わない）
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local acc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasAcceIcon() end,tp,LOCATION_ENA,0,0,3,nil)
    for x in acc:Iter() do
      local hosts=Duel.GetMatchingGroup(function(h) return h:IsSigni() and not h:IsAcce() end,tp,LOCATION_SZONE,0,nil)
      if hosts:GetCount()==0 then break end
      local h=Duel.SelectCards(tp,hosts,0,1):GetFirst()
      if h then Duel.Acce(x,h) end
    end
  end)
  c:RegisterEffect(e1)
end
