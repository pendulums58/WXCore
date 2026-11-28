-- WXK09-015 コード・ピルルク　Ｗ
-- 【自】：あなたのメインフェイズ開始時、あなたのルリグデッキに《改造素材》１枚を加える。
-- 【出】：あなたのトラッシュから＜電機＞のシグニを２枚まで対象とし、それらをエナゾーンに置く。その後、あなたのエナゾーンからシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ゲーム１回》カタルシス《コインアイコン》：対戦相手のシグニ１体を対象とし、それをゲームから除外する。次の対戦相手のターン終了時まで、対戦相手はこの方法でゲームから除外したシグニと同じ名前のシグニを新たに場に出せない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    Duel.AddCraft(6974,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    local h=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,2,nil)
    if h:GetCount()>0 then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  -- 「同じ名前のシグニを新たに場に出せない」는 아직
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Exclude(tc)
    end
  end)
  c:RegisterEffect(e3)
end
