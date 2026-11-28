-- WXEX1-81Re 選択する物語
-- 以下の２つから１つを選ぶ。
-- ①あなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、カードを１枚引き、このカードをゲームから除外する。
-- ②あなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの一番上のカードをエナゾーンに置き、このカードをゲームから除外する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0 then
      if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
      Duel.Exclude(e:GetHandler())
    end
  end)
  c:RegisterEffect(e1)
end
