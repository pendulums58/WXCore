-- WX14-056 幻竜　ダハーカ
-- 【出】：あなたにダメージを与える。（コストのない出現時能力は発動しないことを選べない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.Damage(tp)
  end)
  c:RegisterEffect(e1)
end
