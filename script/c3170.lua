-- WX21-003 とどめはあーや！Ⅴ
-- 【常】：このルリグはこのカードの下にあるルリグの【自】能力を持つ。
-- 【起】《ターン１回》あなたの【トラップ】１つを手札に加える：対戦相手のシグニ１体を対象とし、それを手札に戻す。その後、あなたの手札からカードを３枚まで【トラップ】としてあなたのシグニゾーンに設置する。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、それを【トラップ】としてそのシグニゾーンに設置する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「下にあるルリグの【自】能力を持つ」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    for x in Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),0,3):Iter() do Duel.SetTrap(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCoinCost(2)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then -- 「そのシグニゾーンに【トラップ】として設置」: 존은 고르는 것으로 근사
        Duel.SetTrap(tc,1-tp) end
  end)
  c:RegisterEffect(e2)
end
