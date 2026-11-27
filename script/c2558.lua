-- WX12-032 ＴＯＲＮＡＤＯ
-- このスペルを使用する際、手札から青のスペルを１枚捨ててもよい。そうした場合、このスペルの使用コストは《青×2》減る。
-- 対戦相手のシグニ１体を対象とし、あなたの手札の枚数が対戦相手の手札の枚数以上の場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local picked
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.GetMatchingGroup(s.blue,tp,LOCATION_HAND,0,e:GetHandler()):GetCount()>0 and Duel.ReduceCost(base,"{U}",2) or base end)
  e1:SetDeclare(function(e,tp)
    local g=Duel.GetMatchingGroup(s.blue,tp,LOCATION_HAND,0,e:GetHandler())
    picked=nil
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then
      picked=Duel.SelectCards(tp,g,1,1)
      Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{U}",2))
    end
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked then Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount() then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
function s.blue(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLUE) end
