-- WX15-064 羅菌　キョウギュ
-- 【起】《ダウン》：対戦相手の感染状態のシグニ１体を対象とし、それと同じシグニゾーンにある【ウィルス】１つを取り除き、ターン終了時まで、それのパワーを－7000する。この効果によってそれのパワーが０以下になった場合、カードを１枚引く。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local z=tc:GetZone()
    if z then Duel.RemoveVirus(z) end
    aux.AddPower(e,tc,-7000)  -- [まで]
    if tc:GetPower()<=0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
