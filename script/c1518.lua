-- WDK02-020 ＤＥＶＩＬ　ＳＥＡＬ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜悪魔＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、対戦相手は手札を１枚捨てる。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  -- ＜悪魔＞를 놓지 못하면 버리지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendToTrash(tc,REASON_EFFECT)>0 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
