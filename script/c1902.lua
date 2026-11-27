-- WX02-003 エルドラ×マークⅣ
-- 【自】：あなたのライフクロス１枚がクラッシュされたとき、カードを１枚引いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ダブルクラッシュ】면 두 번(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
