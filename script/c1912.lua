-- WX02-018 火紅柳緑
-- あなたのデッキの一番上を公開する。それが＜鉱石＞か＜宝石＞のシグニの場合、カード２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(top) then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
end
