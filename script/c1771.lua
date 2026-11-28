-- WDK15-008 ハイアングル・バズーカ
-- あなたのシグニの下からカードを合計２枚までトラッシュに置く。その後、この方法でトラッシュに置いたカード１枚につき対戦相手のシグニ１体を対象とし、それらをバニッシュする。
local s,id=GetID()
local function under(tp,f)
  local g=Group.CreateGroup()
  for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    for u in x:GetUnderGroup():Iter() do if not f or f(u) then g:AddCard(u) end end
  end
  return g
end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 한 체에서 2장도, 두 체에서 1장씩도 된다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=under(tp)
    local n=g:GetCount()>0 and Duel.SendToTrash(Duel.SelectCards(tp,g,0,2),REASON_EFFECT) or 0
    if n==0 then return end
    local t=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
    if t:GetCount()>0 then Duel.Banish(t) end
  end)
  c:RegisterEffect(e1)
end
