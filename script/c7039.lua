-- WXK10-065 小装　クワナゴウ
-- 【出】：あなたは手札を１枚捨てる。
-- （コストのない【出】能力は発動しないことを選べない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
