-- WDK13-015 羅星 シーガル
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの場にあるシグニのレベルの合計が対戦相手の場にあるシグニのレベルの合計以下の場合、ターン終了時まで、それのパワーを－3000する。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 조건은 처리할 때 본다
  e1:SetOperation(function(e,tp)
    local function lv(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and lv(tp)<=lv(1-tp) then aux.AddPower(e,tc,-3000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
