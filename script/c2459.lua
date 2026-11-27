-- WX11-002 純白の巫女　ユキ
-- 【自】《ターン１回》：場にあるシグニ１体があなたの効果によって他のシグニゾーンに移動したとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード１：対戦相手のすべてのシグニを好きなように配置し直す。
-- 【起】《ターン１回》エクシード２：対戦相手のシグニ１体を対象とし、それをデッキに戻し、対戦相手は自分のデッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 여럿이 옮겨져도 1번(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_SIGNI_MOVED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(1)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetOperation(function(e,tp)
    s.rearrange(tp,1-tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetExceedCost(2)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckShuffle(tc,1-tp) end
  end)
  c:RegisterEffect(e3)
end
-- 시그니를 하나 골라 다른 존으로(차 있으면 맞바꾼다). 그만둘 때까지
function s.rearrange(tp,p)
  for _=1,6 do
    local c=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SIGNI,0,nil),0,1):GetFirst()
    if not c then return end
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(p)) do if z~=c:GetZone() then zones[#zones+1]=z end end
    local z=Duel.SelectZone(tp,zones)
    if not z then return end
    local o=Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,p,LOCATION_SIGNI,0,nil):GetFirst()
    Duel.SwapSigni(c,o or z)
  end
end
