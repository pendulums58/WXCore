-- WXK10-016 創世の鍵　タマ&ユキ
-- 【出】：あなたのデッキから能力を持たないシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》手札を１枚捨てる：対戦相手は手札を１枚捨てる。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and not x:HasAbility() end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp,eg)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler()) e1:SetType(EFFECT_TYPE_SINGLE) e1:SetCode(EFFECT_LOSE_ABILITY) e1:SetReset(RESET_PHASE+PHASE_END) x:GrantEffect(e1) end end
  end)
  c:RegisterEffect(e3)
end
