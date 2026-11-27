-- WX04-040 極壊　ハンマ
-- 【常】：あなたの場に＜ウェポン＞のシグニがあるかぎり、このシグニの基本パワーは15000になる。
-- 【起】＜アーム＞のシグニ１体と＜ウェポン＞のシグニ１体を場からトラッシュに置く：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：手札から＜アーム＞のシグニ１枚と＜ウェポン＞のシグニ１枚を捨てる。そうした場合、対象の対戦相手のシグニ１体を手札に戻し、対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,tp,LOCATION_SZONE,0,nil)
    local w=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return a:GetCount()>0 and w:GetCount()>0 and (a:GetCount()+w:GetCount()>2 or not a:IsContains(w:GetFirst())) end
    local g=Duel.SelectCards(tp,a,1,1)
    g:AddCard(Duel.SelectCards(tp,w:Filter(function(x) return not g:IsContains(x) end,nil),1,1):GetFirst())
    Duel.SendToTrash(g,REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.bounce=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.ban=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,s.bounce):GetFirst()
  end)
  e2:SetOperation(function(e,tp)
    -- 패는 비공개라 버리지 않아도 된다
    local a=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)
    local w=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)
    if a:GetCount()==0 or w:GetCount()==0 then return end
    a:AddCard(w:GetFirst())
    if Duel.SendToTrash(a,REASON_EFFECT+REASON_DISCARD)<2 then return end
    if s.bounce and s.bounce:IsRelateToEffect(e) then Duel.SendToHand(s.bounce) end
    if s.ban and s.ban:IsRelateToEffect(e) then Duel.Banish(s.ban) end
  end)
  c:RegisterEffect(e2)
end
