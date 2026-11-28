-- WXK06-002 アンシエント・グルーヴ
-- あなたのセンタールリグが＜ウムル＞の場合、このアーツの使用コストは《青×2》減る。
-- 対戦相手のシグニ１体を対象とし、それをダウンする。カードを２枚引き、対戦相手は手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,2)
    aux.Discard(1-tp,2)
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_UMR) end)() then return Duel.ReduceCost(base,"{U}{U}",1) end return base end)
end
