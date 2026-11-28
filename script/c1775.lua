-- WDK15-013 轟書　エンキリデ
-- 【自】：あなたのターン終了時、あなたのシグニの下にある＜ウェポン＞のシグニを１枚まで対象とし、それを手札に加える。
-- 【起】《ターン１回》《黒×0》：対象のあなたのシグニ１体を対象のあなたの＜ウェポン＞のシグニ１体の下に置く。（そのシグニの下にあるカードも一緒に移動する）
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.under(tp,f)
  local g=Group.CreateGroup()
  for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    for u in x:GetUnderGroup():Iter() do if not f or f(u) then g:AddCard(u) end end
  end
  return g
end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  -- 아래에 있는 카드를 대상으로 하는 것은 고르는 것으로 근사
  e1:SetOperation(function(e,tp)
    local g=s.under(tp,s.weapon)
    local tc=g:GetCount()>0 and Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,s.weapon,tp,LOCATION_SZONE,0,1,1,a)
  end)
  -- 아래에 있던 카드도 같이 옮긴다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local first=Duel.GetFirstTarget()
    local host
    for x in Duel.GetTargets():Iter() do if x~=first then host=x end end
    if not (first and host and first:IsRelateToEffect(e) and host:IsRelateToEffect(e)) then return end
    local u=first:GetUnderGroup()
    if u:GetCount()>0 then Duel.PutUnder(host,u) end
    Duel.PutUnder(host,first)
  end)
  c:RegisterEffect(e2)
end
