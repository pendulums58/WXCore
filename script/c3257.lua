-- WX22-035 鍛冶の名工　≡ヘパイス≡
-- 【出】：あなたのトラッシュから対象のレベル４以下の＜天使＞のシグニ１枚を対象のあなたの＜天使＞のシグニ１体の下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.b and s.a:IsRelateToEffect(e) and s.b:IsRelateToEffect(e) then Duel.PutUnder(s.b,Group.CreateGroup(s.a)) end
  end)
  c:RegisterEffect(e1)
end
