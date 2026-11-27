-- WX09-Re06 デス・ブーケトス
-- このターン、あなたがリフレッシュをしたとき、それがこのターンであなたの最初のリフレッシュである場合、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 그 턴 첫 리프레시
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_REFRESH)
    e1:SetCondition(function(e2,tp2,eg,ep) return ep==tp and Duel.GetRefreshCount(tp)==1 end)
    e1:SetOperation(function() Duel.Crush(1-tp,1) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
