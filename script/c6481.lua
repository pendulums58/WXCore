-- WXK04-025-CB Ｅ・Ｇ　ＵＮＩＯＮ　イザベラ
-- 【自】：あなたのメインフェイズ開始時、【エナチャージ１】をする。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置き、エナゾーンにあるすべてのカードをトラッシュに置く：対戦相手のシグニ１体を対象とし、この方法でエナゾーンからカードを
-- １枚以上トラッシュに置いた場合、ターン終了時まで、それの基本パワーを１にする。
-- ５枚以上トラッシュに置いた場合、ターン終了時まで、対戦相手のすべてのシグニの基本パワーを１にする。
-- ９枚以上トラッシュに置いた場合、追加でターン終了時まで、対戦相手のすべてのシグニは「【自】：このシグニがバニッシュされたとき、あなたのライフクロス１枚をクラッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_KEY)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local n=0
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST) or 0
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local function base1(x)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_SET_BASE_POWER)
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      x:RegisterEffect(e1)
    end
    local tc=Duel.GetFirstTarget()
    if n>=5 then
      for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do base1(x) end
    elseif n>=1 and tc and tc:IsRelateToEffect(e) then
      base1(tc)
    end
    if n<9 then return end
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_BANISHED)
      g:SetOperation(function(e2,tp2) Duel.Crush(tp2,1) end)
      g:SetReset(RESET_PHASE+PHASE_END)
      x:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e2)
end
