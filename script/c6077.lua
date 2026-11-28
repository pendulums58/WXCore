-- WXEX1-43 壁面の芸当　グラフィ
-- 【自】：各アタックフェイズ開始時、あなたのエナゾーンから＜美巧＞のシグニを１枚まで対象とし、それを場に出す。
-- 【自】：あなたの＜美巧＞のシグニ１体がバニッシュされたとき、対戦相手のシグニ１体を対象とし、手札から＜美巧＞のシグニを１枚捨ててもよい。そうした場合、それを手札に戻す。
-- ライフバースト：【エナチャージ１】をする。その後、この方法で＜美巧＞のシグニがエナゾーンに置かれた場合、対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_BIKOU),tp,LOCATION_ENA,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:GetPreviousControler()==tp and x:IsSigni() and x:IsClass(0,RACE_BIKOU) end,nil):GetCount()>0
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_BIKOU),tp,LOCATION_HAND,0,nil)
    if pool:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local d=Duel.SelectDiscard(tp,1,1,aux.ClassFilter(0,RACE_BIKOU))
    if d:GetCount()>0 and Duel.SendToTrash(d,REASON_DISCARD+REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if Duel.EnaCharge(tp,1)>0 and top and top:IsLocation(LOCATION_ENA) and top:IsSigni() and top:IsClass(0,RACE_BIKOU) then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
