-- WDK10-011 幻竜　アン＝ミラ
-- 【自】《ターン２回》：ガードステップ以外であなたが手札を１枚捨てたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－6000する。
-- 【出】手札から＜龍獣＞のシグニを１枚捨てる：あなたのトラッシュからレベル３以下の＜龍獣＞のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  -- 코스트·룰(엔드 페이즈)로 버려도. 【ガード】만 아니다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    local x=eg:GetFirst()
    return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_HAND) and r&REASON_DISCARD~=0 and r&REASON_GUARD==0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-6000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1,s.ryu))
  -- 코스트로 버린 것도 고를 수 있다(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return s.ryu(x) and x:IsLevelBetween(0,3) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
end
