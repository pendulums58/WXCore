-- WXEX1-75 幻蟲　マダラゾウ
-- 【出】：対戦相手のトラッシュから対象のカード１枚を対象の対戦相手のシグニ１体の【チャーム】にする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》トラッシュにあるこのカードをゲームから除外する：対戦相手のトラッシュから対象のカード１枚を対象の対戦相手のシグニ１体の【チャーム】にする。この能力はあなたのセンタールリグが＜ミュウ＞の場合にしか使用できない。
local s,id=GetID()
local function charm_tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil)
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
local function charm_op(e,tp)
  local card,sig
  for tc in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do
    if tc:IsLocation(LOCATION_TRASH) then card=tc elseif tc:IsLocation(LOCATION_SZONE) then sig=tc end
  end
  if card and sig then Duel.Charm(card,sig) end
end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(charm_tg)
  e1:SetOperation(charm_op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCondition(function(e,tp)
    local l=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    return l and l:IsLrigType(LRIG_MYU)
  end)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Exclude(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(charm_tg)
  e2:SetOperation(charm_op)
  c:RegisterEffect(e2)
end
