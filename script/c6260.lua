-- WXK01-078 コードライド　ポケバイ
-- 【自】：このシグニがドライブ状態になったとき、カードを１枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRIVE)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
