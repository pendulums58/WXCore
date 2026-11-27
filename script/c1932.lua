-- WX02-045 サクリファイス・スラッシュ
-- 対象のあなたのシグニ１体をバニッシュする。そうした場合、対象の対戦相手のシグニ１体をバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 둘을 처리 직전에 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
    end
    -- 내 시그니를 바니시하지 못하면 뒷부분은 하지 않는다(FAQ 2)
    if not (mine and mine:IsRelateToEffect(e) and Duel.Banish(mine)>0) then return end
    if opp and opp:IsRelateToEffect(e) then Duel.Banish(opp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
