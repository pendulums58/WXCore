-- WXK05-073 幻水　ミドカメ
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが7000以上の場合、カードを１枚引き、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if e:GetHandler():GetPower()>=7000 then Duel.Draw(tp,1) Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
