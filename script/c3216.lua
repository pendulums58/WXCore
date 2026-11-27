-- WX21-058 幻水　オヒョウ
-- ライフバースト：以下の４つから２つまで選ぶ。
-- ①対戦相手のセンタールリグ１体を対象とし、それをダウンする。
-- ②対戦相手のシグニ１体を対象とし、それをダウンする。
-- ③カードを１枚引く。
-- ④【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() if tc then Duel.Down(tc) end end
    if m&2~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Down(tc) end end
    if m&4~=0 then Duel.Draw(tp,1) end
    if m&8~=0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
