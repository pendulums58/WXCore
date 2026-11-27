-- WX14-033 大拳　カクシ
-- 【常】：このシグニはあなたの場に＜アーム＞のシグニが２体以上ないかぎり、新たに場に出すことができない。
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、あなたの他のシグニ１体をバニッシュしてもよい。そうした場合、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()<2 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) return eg:GetFirst():GetOwner()~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,h)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) or Duel.Banish(Duel.SelectCards(tp,g,1,1))==0 then return end
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
end
