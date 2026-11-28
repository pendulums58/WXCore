-- WXK01-082 魔海の吸盤　クラーケン
-- 【自】《ターン２回》：あなたが手札を１枚捨てたとき、対戦相手のシグニ１体を対象とし、あなたのターンの場合、ターン終了時まで、それのパワーを－4000する。（手札を２枚捨てた場合２回発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 2장 버리면 2번(카드 주석, FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_HAND) and r&REASON_DISCARD~=0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetTurnPlayer()==tp then aux.AddPower(e,tc,-4000) end
    end
  end)
  c:RegisterEffect(e1)
end
