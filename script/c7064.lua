-- WXK10-090 小書　ガルドラ
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュから対象のシグニ１枚を対象のあなたの＜ウェポン＞のシグニ１体の下に置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local host=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x and host then Duel.PutUnder(host,x) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
