-- WX14-023 コードキャッスル　ヴェルサ
-- 【常】：対戦相手のシグニの【出】能力は発動しない。
-- 【常】：対戦相手のシグニは、対戦相手の効果によって新たに能力を得られない。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《白》：能力を持たない対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘. 「新たに能力を得られない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DISABLE_ABILITY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(ABILITY_ON_PLAY)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{W}")
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:HasAbility() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckBottom(Group.CreateGroup(tc),false) end
  end)
  c:RegisterEffect(e3)
end
