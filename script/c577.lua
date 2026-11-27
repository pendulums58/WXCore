-- WX04-033 羅原姫　Ｎｅ
-- 【常】：対戦相手のスペルの使用コストは《無×1》増える。
-- 【自】：あなたがスペルを使用したとき、ターン終了時まで、あなたのすべての＜原子＞のシグニのパワーを＋2000する。
-- 【起】アップ状態の＜原子＞のシグニ２体をダウンする：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。その後、あなたの場に＜原子＞のシグニがある場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 ライフバースト는 사용이 아니다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_REDUCE_COST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
  e1:SetEnaCost("{C}")
  e1:SetValue(-1)
  c:RegisterEffect(e1)
  -- 상대 스펠을 UseFree로 써도(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  -- [まで] 처리할 때 장에 있는 시그니만
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,2000) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    for x in Duel.SelectCards(tp,g,2,2):Iter() do Duel.Down(x) end
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()==0 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e4)
end
