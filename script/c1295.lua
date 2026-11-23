-- WD19-009 羅菌　ニホコカビ
-- 【自】《ターン１回》：対戦相手の場にある【ウィルス】１つが取り除かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- 【自】：このシグニがアタックしたとき、対戦相手のすべてのシグニゾーンに【ウィルス】を１つずつ置く。
-- ライフバースト：対戦相手のシグニゾーン１つに【ウィルス】１つを置く。ターン終了時まで、そのシグニゾーンにあるシグニのパワーを－8000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 여러 개가 한꺼번에 치워져도 《ターン１回》라 한 번만(FAQ 1). 처리 중에 치워지면 처리와 룰 처리 뒤에 발동(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_VIRUS_REMOVED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==1-tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(s.lbop)
  c:RegisterEffect(e3)
end
-- 시그니가 아니라 존을 고른다: 【ウィルス】가 이미 있어도, 【シャドウ】 시그니가 있어도 된다(FAQ 3·4).
-- 「ターン終了時まで」라 처리할 때 그 존에 있는 시그니에만 건다([まで], 설계: 효과 모델)
function s.lbop(e,tp)
  local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
  if not z then return end
  Duel.PlaceVirus(z)
  for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetZone()==z end,tp,0,LOCATION_SIGNI,nil):Iter() do
    aux.AddPower(e,tc,-8000)  -- [まで] ターン終了時まで
  end
end
