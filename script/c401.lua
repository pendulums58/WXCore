-- PR-K084 ヴィランズ　グズ子＆カーニバル＆あや（第6回大須星決定戦 景品）
-- 【常】：あなたは対戦相手のレベル２以下のルリグによってダメージを受けない。
-- 【自】：あなたのセンタールリグがグロウしたとき、【エナチャージ１】をする。
-- 【起】このキーを場からルリグトラッシュに置く：対象の対戦相手のシグニ１体を手札に戻す。あなたのトラッシュから対象のシグニ１枚を手札に加える。あなたのデッキからシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 레벨 2 이하인 상대 루리그로
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_LRIG_DAMAGE)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(1,0)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return oc and oc:GetLevel()<=2 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_GROW)
  e2:SetRange(LOCATION_KEY)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsLocation(LOCATION_LRIG) end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
    local x=aux.Search(tp,Card.IsSigni,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
