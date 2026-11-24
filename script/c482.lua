-- WD23-006-E バースト・ラッシュ
-- このターン、あなたのライフバーストが発動する場合、代わりにそのライフバーストは二度発動する。このターン、あなたは《バースト・ラッシュ》を使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DOUBLE_BURST)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
    -- [の間] 「このターン」 《バースト・ラッシュ》만
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_USE_ARTS)
    e3:SetTargetRange(1,0)
    e3:SetTarget(function(e,c) return c:GetCode()==id end)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
  end)
  c:RegisterEffect(e1)
end
