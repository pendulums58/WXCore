-- WX05-033 羅石　ペリドット
-- 【出】：対戦相手のパワー15000以下のシグニ１体を対象とし、あなたの場に《羅石　サファイ》と《羅石　ルビル》がある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(15000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(1874) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsCardName(1869) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
