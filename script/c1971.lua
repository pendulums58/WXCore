-- WX03-020 コードアンチ　パルテノ
-- 【出】《黒》《黒》：あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。
-- 【自】：シグニ１体がトラッシュからあなたの場に出たとき、ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。
-- ライフバースト：どちらか１つを選ぶ。①あなたのトラッシュから＜古代兵器＞のシグニ１枚を対象とし、それを場に出す。②対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}{B}")
  -- 코스트로 놓인 시그니도(FAQ 2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  -- 자신이 트래시에서 나온 때도, 2체면 각각(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg)
    local x=eg:GetFirst()
    return x:IsSigni() and x:GetControler()==tp and x:IsPreviousLocation(LOCATION_TRASH)
  end)
  -- [まで] 처리할 때 장에 있는 시그니만
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,2000) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_TRASH,0,1,1,nil) else Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- 존이 없으면 내지 못한다(FAQ 3)
    if e:GetLabel()==0 then Duel.PutOnField(tc,tp) else Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
