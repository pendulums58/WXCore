-- WXEX1-52 死之遊姫　アタリナシ
-- 【自】《ターン１回》：アタックフェイズの間、あなたの＜遊具＞のシグニ１体が場からトラッシュに置かれたとき、あなたのトラッシュからそのシグニより低いレベルを持つ＜遊具＞のシグニ１枚を対象とし、それを場に出す。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの他のシグニ１体を場からトラッシュに置く。そうした場合、それをバニッシュする。
-- ライフバースト：対象の対戦相手のシグニ１体をバニッシュし、対象のあなたのシグニ１体を場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return Duel.GetPhase()==PHASE_ATTACK and eg:Filter(function(x) return x:GetPreviousControler()==tp and x:IsPreviousLocation(LOCATION_SZONE) and x:IsSigni() and x:IsClass(0,RACE_YUGU) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local sc=eg:Filter(function(x) return x:GetPreviousControler()==tp and x:IsPreviousLocation(LOCATION_SZONE) and x:IsSigni() and x:IsClass(0,RACE_YUGU) end,nil):GetFirst()
    local lv=sc and sc:GetLevel() or 0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) and x:GetLevel()<lv end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local my=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler()),1,1):GetFirst()
    if my and Duel.SendToTrash(my,REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do
      if tc:GetControler()~=tp then Duel.Banish(tc) else Duel.SendToTrash(tc,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e9)
end
