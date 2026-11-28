-- WXK06-067 コードメイズ　アトリット
-- 【起】《青》このシグニを場からトラッシュに置く：対戦相手は、自分のシグニ１体と、自分のエナゾーンからカードを２枚まで対象とし、対象としたエナゾーンのカードと手札を合計２枚デッキの一番上に置かないかぎり、対象としたそのシグニをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{U}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local p=1-tp
    local s1=Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst()
    local en=Duel.SelectTarget(p,nil,p,LOCATION_ENA,0,0,2,nil)
    local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
    local pool=Group.CreateGroup()
    for x in en:Iter() do pool:AddCard(x) end
    for x in h:Iter() do pool:AddCard(x) end
    if pool:GetCount()>=2 and Duel.SelectYesNo(p) then
      aux.ToDeckTopInOrder(p,Duel.SelectCards(p,pool,2,2))
      return
    end
    if s1 then Duel.SendToDeckPosition(s1,1) end
  end)
  c:RegisterEffect(e1)
end
