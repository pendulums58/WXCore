-- WD01-009 甲冑　ローメイル
-- 【常】：対戦相手のターンの間、あなたのシグニのパワーを＋1000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 상대 턴 동안. 여러 체면 겹친다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetValue(1000)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  -- 대상이 없으면 아무것도 하지 않는다(FAQ 4)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
