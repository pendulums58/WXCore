-- WDK14-022 熱音の稲光
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜悪魔＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、手札を１枚捨て、カードを２枚引く。（手札を捨てられなくてもカードを２枚引く）
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.akuma=aux.ClassFilter(0,RACE_AKUMA)  -- ＜悪魔＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,s.akuma,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  -- 「そうした場合」: 트래시에 두지 못하면 뒷부분은 없다(FAQ 1). 패가 없어도 2장 뽑는다
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SendToTrash(tc,REASON_EFFECT)>0) then return end
    aux.Discard(tp,1)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
