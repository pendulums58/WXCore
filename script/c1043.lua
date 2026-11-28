-- WXK01-097 幻怪　ドアーフ
-- 【自】：このシグニがアタックしたとき、このターンにあなたがアーツを使用していた場合、カードを１枚引き、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetArtsUsedCount(tp)>0 end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e1)
end
