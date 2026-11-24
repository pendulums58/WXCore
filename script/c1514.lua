-- WDK02-014 魔海の黒槍　シャークスピア
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの手札が２枚以下の場合、ターン終了時まで、それのパワーを－1000する。あなたの手札が０枚の場合、代わりにターン終了時まで、それのパワーを－5000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 패는 처리할 때 본다. [まで] 그 뒤 패가 늘어도 그대로(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc,n=Duel.GetFirstTarget(),Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    if n<=2 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,n==0 and -5000 or -1000) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
