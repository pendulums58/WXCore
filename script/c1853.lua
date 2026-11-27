-- WX01-043 幻水　アライアル
-- 【起】《青》《ダウン》：カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{U}")
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
