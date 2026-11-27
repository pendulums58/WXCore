-- WX02-034 望まぬ衝動
-- シグニ１体を対象とし、あなたのエナゾーンに赤のカードと緑のカードがある場合、それをバニッシュする。
-- ライフバースト：シグニ１体を対象とし、あなたのエナゾーンに赤のカードと緑のカードがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    -- 【マルチエナ】는 그 색을 가진 것이 아니다(FAQ 1)
    local ok=Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_ENA,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,nil):GetCount()>0
    local tc=Duel.GetFirstTarget()
    if ok and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    -- 【マルチエナ】는 그 색을 가진 것이 아니다(FAQ 1)
    local ok=Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_ENA,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,nil):GetCount()>0
    local tc=Duel.GetFirstTarget()
    if ok and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
