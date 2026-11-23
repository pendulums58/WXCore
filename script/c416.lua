-- WD01-015 ゲット・バイブル
-- あなたのデッキからシグニを１枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 있어도 찾지 않았다고 하고 섞기만 해도 된다(FAQ 1)
function s.op(e,tp)
  aux.SearchToHand(tp,Card.IsSigni,1)
end
