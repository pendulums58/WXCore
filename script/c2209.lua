-- WX07-040 羅原　Ｏ
-- 《クロスアイコン》《羅原　H》の右
-- 【クロス出】：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2197,CROSS_RIGHT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
