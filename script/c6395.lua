-- WXK03-021 極装　EXカリバン
-- 【ライズ】レベルの異なるあなたの赤のシグニ２体の上に置く（どちらかのシグニがあるシグニゾーンに出す）
-- 【自】：あなたのアタックフェイズ開始時、このターンにあなたが手札を３枚以上捨てていた場合、対象の対戦相手のシグニ１体をバニッシュする。そうした場合、対戦相手は自分のエナゾーンから対象のカード１枚をトラッシュに置く。
-- 【起】《ターン１回》このシグニの下からカード１枚をトラッシュに置く：ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- ライフバースト：あなたのトラッシュから＜アーム＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】레벨이 다른 적색 시그니 2체 위(근사: 적색 시그니 1체 위)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetDiscardedCount(tp)>=3 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets()
    local s1,en=nil,nil
    for x in g:Iter() do if x:IsLocation(LOCATION_SZONE) then s1=x else en=x end end
    if s1 and s1:IsRelateToEffect(e) and Duel.Banish(s1)>0 and en and en:IsRelateToEffect(e) then Duel.SendToTrash(en,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=e:GetHandler():GetUnderGroup()
    if chk==0 then return u:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    aux.GrantKeyword(e,e:GetHandler(),EFFECT_DOUBLE_CRUSH)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(tc,tp)) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
