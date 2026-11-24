-- WDK07-E13 コードイート　ポッキン
-- 【自】：あなたのターン終了時、このシグニに【アクセ】が付いている場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    if e:GetHandler():IsAcce() then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
