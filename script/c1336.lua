-- WD22-004-U 恵逢の閻魔　ウリス
-- 【出】：《コインアイコン》を得る。その後、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
