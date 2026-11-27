-- WX10-073 ＥＡＴ　ＳＴＡＲ
-- このターン、あなたが次にスペルを使用する場合、それの使用コストは《無×2》減る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン、次に」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REDUCE_COST)
    e1:SetProperty(EFFECT_FLAG_NEXT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
    e1:SetEnaCost("{C}")
    e1:SetValue(2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
