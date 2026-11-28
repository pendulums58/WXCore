-- WXK01-012 烈覇迅雷
-- 対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(12000))
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if tc:GetPower()<=12000 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
