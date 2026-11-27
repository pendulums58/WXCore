-- WX08-040 コードアート　Ｄ・Ｙ
-- 《クロスアイコン》《コードアート　Ｈ・Ｉ》の左
-- 【クロス出】：対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2273,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
end
