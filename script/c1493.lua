-- WX19-029 死之遊姫　†超体感†
-- 【自】：アタックフェイズの間、このシグニがバニッシュされたか効果によって場からトラッシュに置かれたとき、シグニ１体を対象とし、それをアップするかダウンする。
-- 【起】《アタックフェイズアイコン》《黒》《黒》手札から＜遊具＞のシグニを２枚捨てる：このシグニをあなたのトラッシュからダウン状態で場に出す。（この能力は、このシグニがトラッシュにある場合にしか使用できない）
-- ライフバースト：あなたのトラッシュから＜遊具＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local h=e:GetHandler() return Duel.GetPhase()==PHASE_ATTACK and (h:IsLocation(LOCATION_ENA) and r&REASON_BANISH~=0 or h:IsLocation(LOCATION_TRASH) and r&REASON_EFFECT~=0) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if tc:IsUp() then Duel.Down(tc) else Duel.Up(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetEnaCost("{B}{B}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(aux.DiscardCost(2,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end))
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp,false,true) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then return end
    if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e3)
end
