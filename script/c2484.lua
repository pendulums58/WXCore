-- WX11-034 大幻蟲　ナナホシ
-- 【常】：対戦相手の場に【チャーム】があるかぎり、このシグニはバニッシュされない。
-- 【起】《ターン１回》《アタックフェイズアイコン》《黒×0》：シグニ１体を対象とし、ターン終了時まで、それのパワーを場にある【チャーム】１枚につき－3000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：対戦相手のシグニ１体を対象とし、対戦相手のデッキの一番上のカードをそれの【チャーム】にしてもよい。その後、ターン終了時まで、【チャーム】が付いている対戦相手のすべてのシグニのパワーを－8000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-e:GetHandlerPlayer())>0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-3000*((function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(tp)+(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-tp))) end
  end)  -- [まで]
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if tc and tc:IsRelateToEffect(e) and top and not tc:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(top,tc) end
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,x,-8000) end
  end)
  c:RegisterEffect(e3)
end
