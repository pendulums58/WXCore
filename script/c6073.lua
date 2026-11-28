-- WXEX1-39 幻水姫　ハンマーヘッド
-- 【出】《青》《無》：あなたのデッキからそれぞれレベルの異なる＜水獣＞のシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》《青》：対戦相手のシグニ１体を対象とし、このシグニとそれをデッキの一番上に置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、あなたの手札が４枚以上ある場合、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}{C}")
  e1:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    Duel.SetSelectCheck(aux.DistinctLevels)
    local pick=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_SUIJU),nil),0,3)
    if pick:GetCount()>0 then Duel.RevealCards(pick) Duel.SendToHand(pick) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetEnaCost("{U}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToDeckPosition(h,1) end
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<4 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e9)
end
