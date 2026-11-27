-- WX12-047 幻水　ヤリイカ
-- 【自】：このシグニがアタックしたとき、カードを１枚引く。
-- 【自】：あなたのターン終了時、このターンにこのシグニがアタックしていた場合、あなたは手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and e:GetHandler():HasAttacked() end)
  e2:SetOperation(function(e,tp)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
end
