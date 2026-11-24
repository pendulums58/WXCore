-- WDK11-007 サドゥン・クエスチョン
-- ターン終了時まで、対象の対戦相手のシグニ１体は「【常】：アタックできない。」を得る。対戦相手の場にキーがある場合、追加でターン終了時まで、対象の対戦相手のシグニ１体は「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 키가 없어도 둘 다 고른다(FAQ 1). 1체뿐이면 그것만(FAQ 2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,x)
  end)
  e1:SetOperation(function(e,tp)
    local key=Duel.GetMatchingGroup(nil,tp,0,LOCATION_KEY,nil):GetCount()>0
    local first=Duel.GetFirstTarget()
    for tc in Duel.GetTargets():Iter() do
      -- [まで] ターン終了時まで
      if (tc==first or key) and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end
    end
  end)
  c:RegisterEffect(e1)
end
