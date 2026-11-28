-- WXK01-014 ララ・ルー”スタート”
-- 【起】《ターン１回》《赤》《無》：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手のシグニ２体を対象とし、それらをバニッシュする。（１体のシグニだけに使用することはできない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{R}{C}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  -- 1체에는 쓸 수 없다
  e2:SetCondition(function(e,tp) return Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetCount()>=2 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
end
