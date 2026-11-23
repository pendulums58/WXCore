-- WD04-009 幻獣　セイリュ
-- 【常】：あなたの場にあるシグニ３体のパワーがそれぞれ15000以上であるかぎり、このシグニは【ランサー】と「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 얻는 【自】: 아타크 선언과 함께 바니시하고, 그 뒤에 배틀한다(FAQ 1·2)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  local l=Effect.CreateEffect(c)
  l:SetType(EFFECT_TYPE_SINGLE)
  l:SetCode(EFFECT_LANCER)
  -- [の間] 【常】 내 시그니 3체가 모두 15000 이상인 동안 둘 다 얻는다
  for _,ab in ipairs({l,g}) do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_GRANT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_SIGNI,0)
    e1:SetTarget(function(e,x) return x==e:GetHandler() and s.con(e:GetHandlerPlayer()) end)
    e1:SetLabelObject(ab)
    c:RegisterEffect(e1)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
function s.con(tp)
  local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
  return g:Filter(function(x) return x:GetPower()>=15000 end,nil):GetCount()>=3
end
