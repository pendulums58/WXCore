-- WDK11-011 ＧＦ　イザベラ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの他のシグニ１体を場からトラッシュに置いてもよい。そうした場合、それをバニッシュする。
-- 【出】《白》《白》：あなたのデッキから《ＧＦ　イザベラ》以外の＜英知＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
s.eichi=aux.ClassFilter(0,RACE_EICHI)  -- ＜英知＞のシグニ
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
    local tc=Duel.GetFirstTarget()
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler()),0,1)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT)==0 then return end
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}{W}")
  -- 낼 수 없어도 찾고 섞는다(FAQ 3·4)
  e2:SetOperation(function(e,tp)
    local sc=aux.Search(tp,function(x) return s.eichi(x) and not x:IsCardName(id) end,1):GetFirst()
    if sc then Duel.PutOnField(sc,tp) end
    aux.ShuffleDeck(tp)
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
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
