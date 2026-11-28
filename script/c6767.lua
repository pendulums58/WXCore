-- WXK07-069 大成の爆火
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜原子＞のシグニ１体を場からトラッシュに置く。そうした場合、対象の対戦相手のパワー12000以下のシグニ１体をバニッシュする。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if a and Duel.SendToTrash(a,REASON_EFFECT)>0 and b then Duel.Banish(b) end
  end)
  c:RegisterEffect(e1)
end
