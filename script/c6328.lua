-- WXK02-052 空英の仮定　リソキタ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それを凍結する。すでにそれが凍結状態である場合、代わりにカードを１枚引く。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のシグニ１体を対象とし、それをダウンし凍結する。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if tc:IsFrozen() then Duel.Draw(tp,1) else Duel.Freeze(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and true end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e9)
end
