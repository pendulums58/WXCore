-- WX20-026 大幻蟲　§アノマリス§
-- 【自】：このシグニがアタックしたとき、カードを１枚引き、手札を１枚捨てる。
-- 【自】：このシグニがアタックしたとき、あなたの場に他の＜凶蟲＞のシグニがある場合、カードを１枚引く。
-- 【自】：あなたの場にある＜凶蟲＞のシグニの効果であなたがカードを１枚引いたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
-- ライフバースト：カードを１枚引く。その後、手札を１枚捨ててもよい。そうした場合、センタールリグかシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_DRAW)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg,ep,ev,re) return ep==tp and re~=nil and re:GetHandler():IsLocation(LOCATION_SZONE) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end)(re:GetHandler()) end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-4000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 or not Duel.SelectYesNo(tp) or aux.Discard(tp,1)==0 then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() or x:IsType(TYPE_LRIG) end,tp,LOCATION_SZONE+LOCATION_LRIG,LOCATION_SZONE+LOCATION_LRIG,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
  end)
  c:RegisterEffect(e4)
end
