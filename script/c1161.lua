-- WD07-012 コードアンチ　ヴィマナ
-- 【自】：対戦相手のシグニがアタックしたとき、そのシグニのパワーがそのシグニの正面のシグニのパワーより低い場合、アタックしたそのシグニをバニッシュする。
-- 【出】《黒》：対戦相手のシグニ１体を対象とし、あなたのトラッシュからレベルの異なる＜古代兵器＞のシグニ４枚を好きな順番でデッキの一番下に戻す。
--   そうした場合、ターン終了時まで、それのパワーを－10000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
s.kodai=aux.ClassFilter(0,RACE_KODAIHEIKI)  -- ＜古代兵器＞のシグニ
function s.initial_effect(c)
  -- 어택 선언 때 조건을 본다. 【アサシン】이어도, 배틀이 없어도(FAQ 1·5).
  -- 트리거한 뒤 이 시그니가 장을 떠나도 바니시한다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep)
    if ep==tp then return false end
    local a=eg:GetFirst()
    if not (a and a:IsSigni()) then return false end
    local f=a:GetFrontCard()
    return f~=nil and a:GetPower()<f:GetPower()
  end)
  e1:SetOperation(function(e,tp,eg)
    local a=eg:GetFirst()
    if a and a:IsLocation(LOCATION_SZONE) then Duel.Banish(a) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで(FAQ 3)
  end)
  c:RegisterEffect(e3)
end
-- 0장이나 레벨이 다른 4장 중 하나(FAQ 4). 코스트로 트래시에 간 카드도 고를 수 있다(FAQ 6)
function s.op(e,tp)
  local g=Duel.GetMatchingGroup(s.kodai,tp,LOCATION_TRASH,0,nil)
  Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
  local sg=Duel.SelectCards(tp,g,0,4)
  if sg:GetCount()~=4 then return end
  Duel.SendToDeckBottom(Duel.SelectOrder(tp,sg),false)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで(FAQ 3)
end
