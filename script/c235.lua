-- PR-370 大槍　ヴァルキリー
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル３以下のシグニ１体を対象とし、手札からカード名に《槍》を含むシグニを１枚捨ててもよい。そうした場合、それをトラッシュに置く。
-- 【出】：あなたのデッキの上からカードを４枚公開し、その中からカード名に《槍》を含むシグニ１枚を手札に加える。残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：対戦相手のレベル２以下のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local yari=function(x) return x:IsSigni() and aux.NameHas(x,"槍") end
    if not (tc and tc:IsRelateToEffect(e)) or Duel.GetMatchingGroup(yari,tp,LOCATION_HAND,0,nil):GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1,yari),REASON_EFFECT+REASON_DISCARD)
    Duel.SendToTrash(tc,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 3장 이하면 전부(FAQ 3)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and aux.NameHas(x,"槍") end,nil),1,1)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
