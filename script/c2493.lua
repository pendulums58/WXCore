-- WX11-044 ＳＨＯＯＴＩＮＧ
-- このスペルを使用する際、手札からスペルを３枚捨ててもよい。そうした場合、このスペルの使用コストは《青×3》減る。
-- 対戦相手は手札を３枚捨てる。
-- ライフバースト：対戦相手は無色のカードを１枚捨てないかぎり手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local picked
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) and x~=e:GetHandler() end,tp,LOCATION_HAND,0,nil):GetCount()>=3 and Duel.ReduceCost(base,"{U}",3) or base end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) and x~=e:GetHandler() end,tp,LOCATION_HAND,0,nil)
    picked=nil
    if g:GetCount()>=3 and Duel.SelectYesNo(tp) then
      picked=Duel.SelectCards(tp,g,3,3)
      Duel.SetUseCost(Duel.ReduceCost(base,"{U}",3))
    end
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked then Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD) end
  end)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,3)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:GetColor()==0 end,1-tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(1-tp) then
      Duel.SendToTrash(Duel.SelectCards(1-tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
    else
      aux.Discard(1-tp,2)
    end
  end)
  c:RegisterEffect(e2)
end
