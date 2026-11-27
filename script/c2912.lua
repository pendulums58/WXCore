-- WX17-020 エニー・チョイス
-- 以下の３つから１つを選ぶ。
-- ①カードを２枚引き、手札を１枚捨てる。
-- ②対戦相手のシグニ１体を対象とし、それをダウンする。手札を１枚捨てる。
-- ③対戦相手のセンタールリグ１体を対象とし、それを凍結する。手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then Duel.Draw(tp,2)
    elseif m==1 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Down(tc) end
    else local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() if tc then Duel.Freeze(tc) end end
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
