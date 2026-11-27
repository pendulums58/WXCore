-- WX18-033 超罠　ギジドウ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、手札から《トラップアイコン》を持つシグニを２枚捨ててもよい。そうした場合、それをバニッシュする。
-- 【出】：あなたのトラッシュから《超罠　ギジドウ》以外の《トラップアイコン》を持つシグニ１枚を対象とし、それを手札に加える。
-- 【トラップアイコン】：あなたのエナゾーンから＜トリック＞のシグニ１枚を対象とし、《青》《青》を支払ってもよい。そうした場合、それを場に出す。
-- ライフバースト：あなたの場に【トラップ】がある場合、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasTrapIcon() end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT+REASON_DISCARD)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:HasTrapIcon() end)(x) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
    if Duel.CanPayEna(tp,"{U}{U}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}"),REASON_COST)
      Duel.PutOnField(tc,tp)
    end
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil):GetCount()>0 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e4)
end
