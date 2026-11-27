-- WX14-045 千夜の五夜　シャフリ
-- 【出】レベル１のシグニ１体とレベル２のシグニ１体を場からトラッシュに置く：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：あなたのトラッシュからレベル２以下の黒のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==1 end,tp,LOCATION_SZONE,0,nil)
    local b=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==2 end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return a:GetCount()>0 and b:GetCount()>0 end
    local g=Duel.SelectCards(tp,a,1,1)
    g:Merge(Duel.SelectCards(tp,b,1,1))
    Duel.SendToTrash(g,REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then return end
    -- 예 = 장에 낸다, 아니오 = 패에 넣는다
    if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
end
