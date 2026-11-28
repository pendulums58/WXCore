-- WXK01-054 魔海の船員　ドレイク
-- 【出】手札を２枚捨てる：このターン終了時、カードを２枚引く。（ターン終了時にこのシグニが場になくてもカードを引く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(2))
  e1:SetOperation(function(e,tp,eg)
    -- 이 시그니가 없어도 뽑는다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetOperation(function() Duel.Draw(tp,2) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
