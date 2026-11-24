-- WDK11-008 スタディ・ハード
-- あなたのデッキからシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,Card.IsSigni,2)
  end)
  c:RegisterEffect(e1)
end
