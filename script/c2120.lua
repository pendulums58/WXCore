-- WX05-059 延命の選択
-- 以下の２つから２つまで選ぶ。
-- ①対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手のパワー10000以下のシグニ１体を対象とし、あなたのセンタールリグがレベル４以上で赤の場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.a=m&1~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
    s.b=m&2~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local g=Group.CreateGroup()
    if s.a and s.a:IsRelateToEffect(e) then g:AddCard(s.a) end
    if s.b and s.b:IsRelateToEffect(e) and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 and lc:IsColor(COLOR_RED) end)() then g:AddCard(s.b) end
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
