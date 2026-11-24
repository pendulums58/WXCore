-- WDK05-R12 占英の星術　ホロスチャート
-- 【出】：対戦相手のシグニ１体を対象とし、それを凍結する。
-- 【出】：対戦相手の場に凍結状態のシグニが３体ある場合、対戦相手は手札を１枚捨てる。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- （凍結状態のシグニは自分のアップフェイズが終了すると凍結状態ではなくなる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 위의 능력을 먼저 발동해 3체로 만들어도 된다(FAQ 1)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()==3 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e2)
end
