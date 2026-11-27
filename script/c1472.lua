-- WX18-029 幻怪姫　サトリーナ
-- 【出】：対戦相手のシグニ１体に付いているすべてのカードと、下に置かれているすべてのカードをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》《白》手札からこのカードを捨てる：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失い、新たに得られない。この能力はあなたのセンタールリグが＜ドーナ＞の場合しか使用できない。
-- ライフバースト：カードを１枚引く。次のあなたのターン、対戦相手の場にあるシグニは能力を失い、新たに得られない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local g=tc:GetUnderGroup()
    local ch=tc:GetCharm()
    if ch then g:AddCard(ch) end
    for x in Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==tc end,tp,0,LOCATION_ACCE,nil):Iter() do g:AddCard(x) end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_HAND)
  e2:SetEnaCost("{W}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST+REASON_DISCARD)
  end)
  e2:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_DONA) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    -- [の間] 「次のあなたのターン」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetTargetRange(0,LOCATION_SZONE)
    e1:SetCondition(function() return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>now end)
    e1:SetReset(RESET_PHASE+PHASE_END,3)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
