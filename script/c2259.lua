-- WX08-013 ロブ・ムーブ
-- このカードはあなたの場にクロス状態のシグニがある場合にしか使用できない。
-- 対戦相手のすべてのシグニをダウンし凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    Duel.Down(g)
    Duel.Freeze(g)
  end)
  c:RegisterEffect(e1)
end
