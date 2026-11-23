-- WD01-007 エイボン
-- あなたのデッキから白のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.white(c) return c:IsSigni() and c:IsColor(COLOR_WHITE) end
-- 0~2장, 미리 장 수를 정하지 않는다(FAQ 2. 용어집: 探す)
function s.op(e,tp)
  aux.SearchToHand(tp,s.white,2)
end
