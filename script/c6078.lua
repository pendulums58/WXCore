-- WXEX1-44 コードオーダー　とんラー
-- 【自】：各アタックフェイズ開始時、あなたの【アクセ】の枚数以下のレベルを持つ対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
-- 【出】：あなたの手札から《アクセアイコン》を持つシグニを２枚までエナゾーンに置く。その後、あなたのエナゾーンからこの方法でエナゾーンに置いたカードと同じ枚数の＜調理＞のシグニを対象とし、それらを手札に加える。
-- ライフバースト：あなたのトラッシュから＜調理＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_ACCE,0,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasAcceIcon() end,tp,LOCATION_HAND,0,nil)
    local pick=Duel.SelectCards(tp,pool,0,2)
    local n=pick:GetCount()>0 and Duel.SendToEna(pick,REASON_EFFECT) or 0
    if n>0 then
      local eg=Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_CHOURI),tp,LOCATION_ENA,0,n,n,nil)
      if eg:GetCount()>0 then Duel.SendToHand(eg) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_CHOURI),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e9)
end
