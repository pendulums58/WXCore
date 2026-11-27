-- WX04-037 フィア＝リカブト
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対戦相手のすべてのシグニのパワーをあなたの場にある＜毒牙＞のシグニ１体につき－1000する。
-- 【自】：あなたのターンの間、対戦相手のシグニ１体が場からトラッシュに置かれたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：ターン終了時まで、対象のシグニ１体のパワーを－10000する。あなたの場に＜毒牙＞のシグニがある場合、追加でターン終了時まで、対象のシグニ１体のパワーを－7000する。（同じシグニを対象とすることもできる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- [まで] 처리할 때 장에 있는 시그니만
  e1:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n==0 then return end
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-1000*n) end
  end)
  c:RegisterEffect(e1)
  -- 함께 트래시에 놓여도 트리거한다(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()==tp and x:GetOwner()~=tp and x:IsPreviousLocation(LOCATION_SZONE) end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  -- 같은 시그니도 된다
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
    s.a,s.b=a,nil
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst() end
  end)
  e3:SetOperation(function(e,tp)
    -- [まで] ターン終了時まで
    if s.a and s.a:IsRelateToEffect(e) then aux.AddPower(e,s.a,-10000) end
    if s.b and s.b:IsRelateToEffect(e) then aux.AddPower(e,s.b,-7000) end
  end)
  c:RegisterEffect(e3)
end
