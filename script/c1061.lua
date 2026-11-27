-- WX21-011 ドント・ファイト
-- 対戦相手のシグニ１体を対象とし、それをダウンする。それが白か赤のシグニの場合、追加でカードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) if tc:IsColor(COLOR_WHITE) or tc:IsColor(COLOR_RED) then Duel.Draw(tp,2) end end
  end)
  c:RegisterEffect(e1)
end
