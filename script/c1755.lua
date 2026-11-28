-- WDK14-007 緩急火号
-- カードを２枚引き、【エナチャージ２】をし、あなたのライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 위에서부터 차례로. 라이프가 없으면 크러시만 하지 않는다(FAQ 2·3)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    Duel.EnaCharge(tp,2)
    Duel.Crush(tp,1)
  end)
  c:RegisterEffect(e1)
end
