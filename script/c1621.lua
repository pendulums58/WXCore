-- WDK07-E08 キャンディ・レイン
-- 以下の３つから１つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをダウンする。
-- ②カードを２枚引く。
-- ③スペル１枚を対象とし、それの効果を打ち消し、それをトラッシュから対戦相手の手札に戻す。このターン、対戦相手はそれと同じ名前のカードを使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local mode=e:GetLabel()
    if mode==0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    elseif mode==1 then
      Duel.Draw(tp,2)
    else
      local sp=Duel.GetCutinSpell()
      if not sp then return end
      Duel.NegateSpell(true)
      -- [の間] 「このターン」. 패로 돌아가지 못해도(FAQ 1)
      local code=sp:GetCode()
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_CANNOT_USE)
      e1:SetTargetRange(0,1)
      e1:SetTarget(function(e,x) return x:IsCardName(code) end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
