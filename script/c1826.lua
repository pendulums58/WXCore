-- WX01-006 四式戦帝女　緑姫
-- 【起】手札から緑のシグニを１枚捨てる：あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
