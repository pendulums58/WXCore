-- WX06-006 アンシエント・ゲート
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。あなたのセンタールリグが黒で、あなたのライフクロスが２枚以下の場合、代わりに対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ－15000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel((function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_BLACK) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 end)() and 15000 or 12000)
    if e:GetLabel()==15000 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil) else Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    -- [まで] ターン終了時まで
    for tc in g:Iter() do aux.AddPower(e,tc,-e:GetLabel()) end
  end)
  c:RegisterEffect(e1)
end
