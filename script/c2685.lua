-- WX14-021 カース・オブ・スペル
-- 対戦相手のトラッシュにあるすべてのスペルをゲームから除外する。その後、この方法でスペルを３枚以上ゲームから除外した場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,nil)
    local n=g:GetCount()>0 and Duel.Exclude(g) or 0
    if n<3 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
