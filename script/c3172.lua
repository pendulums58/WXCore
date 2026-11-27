-- WX21-005 ナナシ　其ノ後
-- 【常】：対戦相手の感染状態のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- 【出】：あなたのトラッシュからシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ダウン》：対戦相手のすべてのシグニゾーンに【ウィルス】を１つずつ置く。
-- 【起】《アタックフェイズアイコン》《コインアイコン》：対戦相手の感染状態のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_TO_TRASH)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsInfected() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCost(aux.SelfDownCost)
  e3:SetOperation(function(e,tp)
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCoinCost(1)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1) end
  end)
  c:RegisterEffect(e4)
end
