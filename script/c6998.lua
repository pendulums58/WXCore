-- WXK10-024 古代の炎魔　グレンデ
-- 【常】：あなたの他の赤のシグニは対戦相手の効果によって能力を失わない。
-- 【自】《ターン１回》：あなたが赤のスペルを使用したとき、【エナチャージ１】をする。
-- 【自】：あなたのアタックフェイズ開始時、あなたの【ダブルクラッシュ】を持つ赤のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
-- ライフバースト：あなたのトラッシュから赤のカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「あなたの他の赤のシグニは対戦相手の効果によって能力を失わない」는 아직
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_SPELL) and x:IsColor(COLOR_RED) end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:HasKeyword(EFFECT_DOUBLE_CRUSH) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_ASSASSIN)
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
