-- WXK10-045 北風の蒼天　ボレアース
-- 【自】：あなたのアタックフェイズ開始時、あなたの手札が対戦相手より多い場合、その枚数の差以下のレベルを持つ対象の対戦相手のシグニ１体をバニッシュする。
-- 【出】：対戦相手は手札を１枚チェックゾーンに置く。このターン終了時、対戦相手はそれを手札に戻す。
-- ライフバースト：対戦相手は手札を１枚捨てる。あなたの手札が３枚以下の場合、あなたはカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil):GetCount() end)
  e1:SetOperation(function(e,tp,eg)
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()-Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil):GetCount()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「チェックゾーンに置く…ターン終了時、手札に戻す」
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 then return end
    local x=Duel.SelectCards(1-tp,h,1,1):GetFirst()
    if Duel.SendToCheck(x)==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetCountLimit(1)
    e1:SetOperation(function() if x:IsLocation(LOCATION_CHECK) then Duel.SendToHand(x) end end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(1-tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=3 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e9)
end
