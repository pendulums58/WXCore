-- WD13-002 愛幸の巫女　ユキ
-- 【常】：このカードにグロウする際、手札からシグニを２枚まで公開する。この方法で＜迷宮＞のシグニを公開した場合、このカードにグロウするためのコストは《白×1》減り、＜毒牙＞の場合、《黒×1》減る。
-- 【常】：対戦相手のターンの間、あなたのシグニのパワーをあなたの＜迷宮＞のシグニ１体につき＋1000する。
-- 【常】：あなたのターンの間、対戦相手のシグニのパワーをあなたの＜毒牙＞のシグニ１体につき－1000する。
local s,id=GetID()
function s.initial_effect(c)
  local picked  -- 공개는 시그니라면 무엇이든, 안 해도 된다(FAQ 1·2)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetAbilityType(ABILITY_CONTINUOUS)
  e0:SetMinCost(function(e,tp) return s.cost(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil)) end)
  e0:SetDeclare(function(e,tp)
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,s.cost(g)) end)
    picked=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil),0,2)
    Duel.SetUseCost(s.cost(picked))
  end)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked:GetCount()>0 then Duel.RevealCards(picked) end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e1:SetValue(function(e) return 1000*s.count(e,RACE_MEIKYU) end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(0,LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e2:SetValue(function(e) return -1000*s.count(e,RACE_DOKUGA) end)
  c:RegisterEffect(e2)
end
function s.count(e,race)
  return Duel.GetMatchingGroup(aux.ClassFilter(0,race),e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()
end
function s.cost(g)
  local meikyu=g:Filter(aux.ClassFilter(0,RACE_MEIKYU),nil):GetCount()>0
  local dokuga=g:Filter(aux.ClassFilter(0,RACE_DOKUGA),nil):GetCount()>0
  return (meikyu and "" or "{W}")..(dokuga and "" or "{B}").."{C}"
end
