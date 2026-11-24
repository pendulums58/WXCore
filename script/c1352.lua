-- WD22-029-G 死之遊　†マージャン†
-- 【自】：対戦相手のアタックフェイズの間、対戦相手がカードを１枚引いたとき、対戦相手のシグニ１体を対象とし、それをダウンする。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのシグニ１体を場からトラッシュに置いてもよい。そうした場合、それをトラッシュに置く。
-- ライフバースト：あなたのデッキの上からカードを４枚公開する。その中から＜遊具＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
local s,id=GetID()
s.yugu=aux.ClassFilter(0,RACE_YUGU)  -- ＜遊具＞のシグニ
function s.initial_effect(c)
  -- 1장마다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRAW_ONE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep)
    return ep~=tp and Duel.GetTurnPlayer()~=tp and Duel.GetPhase()==PHASE_ATTACK
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 자신도 놓을 수 있다(FAQ 3)
  e2:SetOperation(function(e,tp)
    local tc,g=Duel.GetFirstTarget(),Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if not tc or g:GetCount()==0 then return end
    local x=Duel.SelectCards(tp,g,0,1)
    if x:GetCount()>0 and Duel.SendToTrash(x,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local _,rest=aux.ExcavateToHand(tp,4,s.yugu,0,2)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
