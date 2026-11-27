-- WX17-030 大幻蟲　§スノセク§
-- 【自】：各アタックフェイズ開始時、カードを１枚引いてもよい。そうした場合、手札を１枚捨てる。
-- 【自】：効果によってあなたのシグニ１体が場に出たとき、対戦相手のシグニ１体を対象とし、それをダウンする。
-- 【出】《青》：あなたのトラッシュからレベル３以下の＜凶蟲＞のシグニを２枚まで対象とし、それらを手札に加える。そうした場合、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) aux.Discard(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep,ev,re) return eg:GetFirst():GetControler()==tp and re~=nil end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{U}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 and Duel.SendToHand(g)>0 then aux.Discard(tp,1) end
  end)
  c:RegisterEffect(e3)
end
