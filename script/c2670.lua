-- WX14-004 炎竜毒蛇
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ－8000する。
-- ②対戦相手のパワー7000以下のすべてのシグニをバニッシュする。
-- ③【アサシン】【ランサー】【ダブルクラッシュ】のいずれかを持つすべてのシグニをバニッシュする。
-- ④あなたのトラッシュからシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t0=m&1~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil) or nil
    s.t3=m&8~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,nil) or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 and s.t0 then for x in s.t0:Iter() do if x:IsRelateToEffect(e) then aux.AddPower(e,x,-8000) end end end
    if m&2~=0 then local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,nil) if g:GetCount()>0 then Duel.Banish(g) end end
    if m&4~=0 then local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:HasKeyword(EFFECT_ASSASSIN) or x:HasKeyword(EFFECT_LANCER) or x:HasKeyword(EFFECT_DOUBLE_CRUSH)) end,tp,LOCATION_SZONE,LOCATION_SZONE,nil) if g:GetCount()>0 then Duel.Banish(g) end end
    if m&8~=0 and s.t3 then local h=s.t3:Filter(function(x) return x:IsRelateToEffect(e) end,nil) if h:GetCount()>0 then Duel.SendToHand(h) end end
  end)
  c:RegisterEffect(e1)
end
