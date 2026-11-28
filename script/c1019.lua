-- SPK01-15 魔界の五裁　マルバス（パーティーパックVol.5）
-- 【自】：対戦相手のターン終了時、あなたのトラッシュから無色ではないシグニ１枚を対象とし、あなたの手札が０枚の場合、それを手札に加える。
-- 【出】：対戦相手のシグニ１体を対象とし、対戦相手の手札があなたより５枚以上多い場合、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 2체여도 손패가 0장일 때만이라 1장(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local mine=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    local theirs=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()
    if tc and tc:IsRelateToEffect(e) and theirs>=mine+5 then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
