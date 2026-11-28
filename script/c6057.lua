-- WXEX1-23 静観の冥者　ハナレ
-- 【出】：あなたのトラッシュから＜毒牙＞のシグニ１枚を対象とし、それを場に出す。
-- 【起】《ターン１回》《アタックフェイズアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、手札から＜毒牙＞のシグニを１枚捨てる。ターン終了時まで、それのパワーをこの方法で捨てたシグニのパワーと同じだけ－（マイナス）する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_DOKUGA),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local d=Duel.SelectDiscard(tp,1,1,aux.ClassFilter(0,RACE_DOKUGA)):GetFirst()
    if not d then return end
    local pw=d:GetPower()
    if Duel.SendToTrash(d,REASON_DISCARD+REASON_EFFECT)>0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) and pw>0 then aux.AddPower(e,tc,-pw) end
    end
  end)
  c:RegisterEffect(e2)
end
