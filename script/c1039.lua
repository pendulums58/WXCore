-- SPK06-05 アーク・クロス・カウンター（「Lostorage conflated WIXOSS 3」 初回特典）
-- このアーツの使用コストとして、追加であなたのセンタールリグの下からカード４枚をルリグトラッシュに置く。
-- 対戦相手のセンタールリグとすべてのシグニをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 아래가 3장 이하면 쓸 수 없다(FAQ 1)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetUnderGroup():GetCount()>=4 end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if chk==0 then return lc and lc:GetUnderGroup():GetCount()>=4 end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,lc:GetUnderGroup(),4,4),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if oc then g:AddCard(oc) end
    if g:GetCount()>0 then Duel.Down(g) end
  end)
  c:RegisterEffect(e1)
end
