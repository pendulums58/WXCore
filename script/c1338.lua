-- WD22-007-G 成就の駄姫　グズ子
-- 【自】《ターン１回》：あなたの＜遊具＞のシグニ１体がトラッシュから場に出たとき、《黒》を支払い、そのシグニを場からトラッシュに置いてもよい。そうした場合、対象の対戦相手のシグニ１体をバニッシュする。
-- 【出】《コインアイコン》：あなたのトラッシュから黒のシグニを２枚まで対象とし、それらを場に出す。
local s,id=GetID()
s.yugu=aux.ClassFilter(0,RACE_YUGU)  -- ＜遊具＞のシグニ
function s.initial_effect(c)
  -- 쓰지 않아도 발동한 것이라 그 턴에는 다시 발동하지 않는다(FAQ 2·3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    local x=eg:GetFirst()
    return s.yugu(x) and x:GetControler()==tp and x:IsPreviousLocation(LOCATION_TRASH)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local x,tc=eg:GetFirst(),Duel.GetFirstTarget()
    if not (x:IsLocation(LOCATION_SZONE) and Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    -- 트래시 대신 다른 곳으로 가도(제외 등) 뒷부분을 처리한다(FAQ 5)
    if Duel.SendToTrash(x,REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e2)
end
