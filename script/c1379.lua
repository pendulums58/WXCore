-- WD23-019-E 幻水姫　アロワナ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの手札が７枚以上の場合、それをデッキの一番上に置く。
-- 【起】《青×0》：対戦相手は自分のデッキの一番上を公開する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
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
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=7 and tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(1-tp,1)
    if g:GetCount()>0 then Duel.RevealCards(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e3)
end
