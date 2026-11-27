-- WX03-003 業火絢爛
-- 対戦相手のセンタールリグが緑の場合、このカードの基本コストは《赤×2》になる。
-- 対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「基本コスト」를 바꾼다
  aux.SetCostBy(e1,function(e,tp,base)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    return lc and lc:IsColor(COLOR_GREEN) and "{R}{R}" or base
  end)
  e1:SetTarget(aux.BanishPowerTarget(15000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
