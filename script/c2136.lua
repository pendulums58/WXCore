-- WX06-012 ミルルン・アト
-- 【出】：このターン、あなたが次にスペルを使用する場合、それの使用コストは《青×1》減る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン、次に」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REDUCE_COST)
    e1:SetProperty(EFFECT_FLAG_NEXT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
    e1:SetEnaCost("{U}")
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
