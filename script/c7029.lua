-- WXK10-055 千匹の童話　センショク
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュから＜美巧＞のシグニ１枚を対象とし、あなたのシグニ１体を場からトラッシュに置いてもよい。そうした場合、それを手札に加える。
-- 【自】：このシグニがバトルによって対戦相手のシグニ１体をバニッシュしたとき、対戦相手のトラッシュからそのシグニのレベル以下のシグニ１枚を対象とし、それを傀儡状態であなたの場に出してもよい。
-- ライフバースト：対戦相手のトラッシュからシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
      if g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)>0 then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep~=tp and (r&REASON_BATTLE)~=0 and Duel.GetBanisher()==e:GetHandler() end)
  e2:SetOperation(function(e,tp,eg)
    local lv=eg:GetFirst():GetLevel()
    local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetLevel()<=lv end,tp,0,LOCATION_TRASH,0,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e9)
end
