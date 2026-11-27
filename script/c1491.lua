-- WX22-024 期之遊姫王　†ブラジャック†
-- 【常】：対戦相手は、自身の効果によって手札以外からシグニを場に出せない。
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたの他のすべてのシグニをバニッシュしてもよい。その後、この方法でバニッシュしたシグニと同じ数だけ、あなたのトラッシュからレベル４以下の＜遊具＞のシグニを対象とし、それらを場に出す。
-- 【出】：あなたのトラッシュからレベル４以下の＜遊具＞のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。その後、あなたのトラッシュからそのシグニと同じレベルの＜遊具＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「自身の効果によって手札以外からシグニを場に出せない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler())
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local n=Duel.Banish(g)
    if n==0 then return end
    for x in Duel.SelectTarget(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(c) and c:GetLevel()<=4 end,tp,LOCATION_TRASH,0,0,n,nil):Iter() do Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local lv=tc:GetLevel()
    Duel.Banish(tc)
    local x=Duel.SelectTarget(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(c) and c:GetLevel()==lv end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e3)
end
