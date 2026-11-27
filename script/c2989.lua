-- WX18-035 幻獣神　コウノト
-- 【常】：あなたのトラッシュに＜空獣＞のシグニが７枚以上あるかぎり、このシグニは対戦相手のシグニの効果を受けない。
-- 【自】《ターン１回》：対戦相手がアーツを使用したとき、あなたのデッキの上からカードを２枚エナゾーンに置いてもよい。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場に＜空獣＞のシグニが３体ある場合、それをバニッシュする。
-- ライフバースト：あなたのトラッシュから＜空獣＞のシグニを２枚まで手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=7 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e2:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end,tp,LOCATION_TRASH,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e4)
end
