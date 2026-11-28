-- WXK02-065 師の遊　カワリエ
-- 【自】：このシグニがアタックしたとき、このターンにシグニが２体以上場から手札に戻っていた場合、【エナチャージ２】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetBouncedCount()>=2 then Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e1)
end
