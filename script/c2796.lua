-- WX15-080 相違の想意
-- 対象の対戦相手のパワー5000以下のシグニ１体をバニッシュする。あなたの場に《ライズアイコン》を持つシグニがある場合、追加で対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,s.a):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.Banish(s.a) end
    if s.b and s.b:IsRelateToEffect(e) and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(s.b) end
  end)
  c:RegisterEffect(e1)
end
