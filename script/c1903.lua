-- WX02-004 無間の閻魔　ウリス
-- 【起】《黒》手札から黒のシグニを１枚捨てる：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetEnaCost("{B}")
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
