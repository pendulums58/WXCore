-- WXEX1-40 羅原姫　Ｙｂ
-- 【常】：あなたの＜原子＞のシグニは、あなたのトラッシュに＜原子＞のシグニが１０種類以上あるかぎり、対戦相手のシグニの効果を受けず、１５種類以上あるかぎり、対戦相手のルリグの効果を受けない。
-- 【自】：このシグニがバニッシュされたとき、あなたのトラッシュに＜原子＞のシグニが５種類以上ある場合、対戦相手は手札を１枚捨てる。
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。
local s,id=GetID()
local function genshi_kinds(tp)
  local seen,n={},0
  for x in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_GENSHI),tp,LOCATION_TRASH,0,nil):Iter() do
    local code=x:GetCode()
    if not seen[code] then seen[code]=true n=n+1 end
  end
  return n
end
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)
  e1:SetValue(function(e,sc,sp)
    if sp==e:GetHandlerPlayer() or not sc then return false end
    local n=genshi_kinds(e:GetHandlerPlayer())
    if n>=10 and sc:IsSigni() then return true end
    if n>=15 and sc:IsType(TYPE_LRIG) then return true end
    return false
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(function(e,tp)
    if genshi_kinds(tp)>=5 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e9:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do
      Duel.Down(x)
      Duel.Freeze(x)
    end
  end)
  c:RegisterEffect(e9)
end
