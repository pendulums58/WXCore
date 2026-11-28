-- WXK09-076 ＳＴＲＡＩＧＨＴ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜天使＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、対戦相手は手札を１枚捨てる。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc and Duel.SendToTrash(tc,REASON_EFFECT)>0 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
