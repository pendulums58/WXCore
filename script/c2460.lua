-- WX11-003 雪月風火　花代・肆
-- 【起】《赤》手札から赤のシグニを１枚捨てる：あなたの赤のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。　
-- 【起】《赤》手札から＜鉱石＞か＜宝石＞のシグニを１枚捨てる：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ターン１回》エクシード２：カードを３枚引く。次のあなたのアタックフェイズ開始時、あなたは手札をすべて捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetEnaCost("{R}")
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) end
  end)  -- [まで]
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetEnaCost("{R}")
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end))
  e2:SetTarget(aux.BanishPowerTarget(12000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetExceedCost(2)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    -- 「次のあなたのアタックフェイズ開始時」
    local done=false
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
    e1:SetCondition(function() return not done and Duel.GetTurnPlayer()==tp end)
    e1:SetOperation(function()
      done=true
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
