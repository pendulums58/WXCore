-- WD16-022 ＴＨＲＥＥ　ＯＵＴ
-- カードを３枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_EFFECT+REASON_DISCARD)
  end)
  c:RegisterEffect(e1)
end
