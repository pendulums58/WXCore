-- WXK09-089 読取
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜電機＞のシグニ１体を対象とし、それを場からトラッシュに置く。その後、この方法でトラッシュに置いたシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    local p=tc:GetPower()
    if Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
    local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if x then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
end
