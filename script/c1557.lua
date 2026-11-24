-- WDK06-C01 カーニバル　†ＱＡ†
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのトラッシュに＜武勇＞のシグニが１０枚以上ある場合、それをトラッシュに置く。　
-- 【起】《ターン１回》デッキの上からカードを３枚トラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)  -- ＜武勇＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 조건은 처리할 때 본다
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(s.buyu,tp,LOCATION_TRASH,0,nil):GetCount()>=10 and tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,3)
    if chk==0 then return g:GetCount()==3 end  -- 2장 이하면 낼 수 없다(FAQ 1)
    Duel.SendToTrash(g,REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
