-- WX10-018 暴風警報
-- このターン、対戦相手のシグニかセンタールリグがアタックしたとき、そのアタックがこのターン一度目か二度目の場合、そのアタックを無効にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 상대의 1·2번째 어택(FAQ 2·3)
    local n=0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) return eg:GetFirst():GetControler()~=tp end)
    e1:SetOperation(function()
      n=n+1
      if n<=2 then Duel.NegateAttack() end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
