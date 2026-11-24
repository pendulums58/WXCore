-- WD16-002 コード　ピルルク・Γ
-- 【出】《青》：対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(function(e,tp) aux.Discard(1-tp,1) end)
  c:RegisterEffect(e1)
end
