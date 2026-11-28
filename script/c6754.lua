-- WXK07-056 羅星　サンレツ
-- 【出】：このターン、あなたのデッキにある＜宇宙＞のシグニのレベルは４になる。（デッキにある間のみレベルが４になる。発動後にデッキに加わったシグニもレベルが４になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    -- [まで] このターン
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetTargetRange(LOCATION_MDECK,0)
    e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_UCHU) end)(x) end)
    e1:SetValue(4)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
