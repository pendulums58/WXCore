-- WXEX1-14 四型開　緑姫
-- 【自】：あなたのアタックフェイズ開始時、あなたのすべての＜植物＞のシグニをアップする。
-- 【起】《アタックフェイズアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、あなたのエナゾーンから＜植物＞のシグニ３枚をトラッシュに置く。そうした場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_SHOKUBUTSU),tp,LOCATION_SZONE,0,nil):Iter() do
      Duel.Up(x)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_SHOKUBUTSU),tp,LOCATION_ENA,0,nil)
    if pool:GetCount()<3 then return end
    local g=Duel.SelectCards(tp,pool,3,3)
    if g:GetCount()==3 and Duel.SendToTrash(g,REASON_EFFECT)==3 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
