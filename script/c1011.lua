-- SPK01-06 島原の一揆　トキサダ（パーティーパックVol.2）
-- 【起】《ターン１回》《黒》デッキの上からカードを４枚トラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{B}")
  -- 3장 이하면 쓸 수 없다(FAQ 1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,4)
    if chk==0 then return g:GetCount()>=4 end
    Duel.SendToTrash(g,REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-4000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
