-- WXEX1-30 羅星姫　レオニズ
-- 【常】：対戦相手の凍結状態のシグニが場を離れる場合、代わりにトラッシュに置かれる。
-- 【自】《ターン１回》：対戦相手の凍結状態のシグニ１体が場を離れたとき、対戦相手のシグニ１体を対象とし、あなたのターンの場合、それを手札に戻す。
-- 【出】《白》《青》：あなたのデッキから白のシグニ１枚と青のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのトラッシュから白のシグニ１枚と青のシグニ１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 凍結状態のシグニが場を離れる場合、代わりにトラッシュ(바니시 대체로 근사)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsFrozen() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:IsSigni() and x:GetOwner()==1-tp and x:IsFrozen() end,nil):GetCount()>0
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()~=tp then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{W}{U}")
  e3:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    local g1=Duel.SelectCards(tp,d:Filter(function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,nil),0,1)
    local g2=Duel.SelectCards(tp,d:Filter(function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,g1:GetFirst()),0,1)
    g1:Merge(g2)
    if g1:GetCount()>0 then Duel.RevealCards(g1) Duel.SendToHand(g1) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local t1=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,tp,LOCATION_TRASH,0,1,1,t1)
  end)
  e9:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
