-- WX08-053 ホワイト・アウト
-- 対象のあなたのアップ状態のレゾナ１体をダウンする。そうした場合、対象の対戦相手のシグニ１体をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_RESONA) and x:IsUp() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e) and s.a:IsUp()) then return end
    Duel.Down(s.a)
    if s.b and s.b:IsRelateToEffect(e) then Duel.SendToTrash(s.b,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
