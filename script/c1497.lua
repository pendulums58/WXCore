-- WX21-044 惨之遊　†シャテキ†
-- 【常】：このシグニがエナゾーンにあるかぎり、あなたは《緑》を支払う際、代わりにあなたのエナゾーンからこのシグニをトラッシュに置いてもよい。
-- 【出】：このシグニが＜遊具＞のシグニの効果によって手札から場に出た場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 【出】：このシグニが＜遊具＞のシグニの効果によってトラッシュから場に出た場合、あなたのトラッシュから＜遊具＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから＜遊具＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「《緑》を支払う際、代わりにトラッシュに置いてもよい」: 에나 존에서 【マルチエナ】로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function(e,tp,eg,ep,ev,re) local h=e:GetHandler() return re~=nil and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(re:GetHandler()) and h:IsPreviousLocation(LOCATION_HAND) end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetCondition(function(e,tp,eg,ep,ev,re) local h=e:GetHandler() return re~=nil and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(re:GetHandler()) and h:IsPreviousLocation(LOCATION_TRASH) end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e4)
end
