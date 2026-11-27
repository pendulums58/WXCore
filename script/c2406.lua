-- WX10-033 コードハート　Ｓ・Ｗ・Ｔ
-- 【常】：このシグニがバニッシュされる場合、代わりに手札からスペルを１枚捨ててもよい。
-- 【出】手札からスペルを１枚捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《アタックフェイズアイコン》手札からスペルを２枚捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのデッキの上からカードを５枚公開する。その中からすべてのスペルを手札に加え、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「バニッシュされる場合、代わりにスペルを捨てる」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsType(TYPE_SPELL) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(aux.DiscardCost(2,function(x) return x:IsType(TYPE_SPELL) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,5))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local sp=g:Filter(function(x) return x:IsType(TYPE_SPELL) end,nil)
    if sp:GetCount()>0 then Duel.SendToHand(sp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e3)
end
