-- WX02-060 ＳＥＡＲＣＨＥＲ
-- あなたのデッキからスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのデッキからスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) end,1)
  end)
  c:RegisterEffect(e2)
end
