-- WXEX1-01 紅翼の巫女　タマヨリヒメ
-- 【常】：あなたのターンの間、あなたの＜ウェポン＞のシグニは対戦相手の効果によってダウンしない。
-- 【常】：対戦相手のターンの間、あなたの＜アーム＞のシグニは対戦相手の効果によってバニッシュされない。
-- 【出】：あなたのデッキから＜アーム＞のシグニ１枚と＜ウェポン＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_BANISH_IMMUNE)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    local g1=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_ARM),nil),0,1)
    local g2=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_WEAPON),g1:GetFirst()),0,1)
    g1:Merge(g2)
    if g1:GetCount()>0 then Duel.RevealCards(g1) Duel.SendToHand(g1) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
