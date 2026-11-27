-- WX08-022 ペイ・チャージング
-- 手札を１枚捨てる。そうした場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    if aux.Discard(tp,1)>0 then Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e1)
end
