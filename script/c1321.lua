-- WD21-006 霹靂閃炎
-- 対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。そうした場合、このカードをあなたのセンタールリグの下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(15000))
  -- 바니시하지 못하면 밑에 놓지 않고 루리그 트래시로(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc,h=Duel.GetFirstTarget(),e:GetHandler()
    if not (tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0) then return end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc and h:IsLocation(LOCATION_CHECK) then Duel.PutUnder(lc,h) end
  end)
  c:RegisterEffect(e1)
end
