-- WX19-027 癒英の治療　＃ナイチール＃
-- 【出】：あなたのトラッシュから＜英知＞のシグニ２枚を対象とし、それらをこのシグニの下に置く。
-- 【常】：このシグニはこのカードの下にあるシグニの【常】の【英知】能力を得る。
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、このシグニの基本レベルを１～３いずれかのレベル１つにしてもよい。
-- ライフバースト：あなたのトラッシュからレベル１の＜英知＞のシグニ１枚とレベル４の＜英知＞のシグニ１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_TRASH,0,2,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  -- 【常】 「下にあるシグニの【常】の【英知】能力を得る」는 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    if m==3 then return end
    local tc=h
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(m+1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x:GetLevel()==1 end,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x:GetLevel()==4 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
