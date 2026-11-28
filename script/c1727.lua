-- WDK12-008 化学分解
-- 対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。対戦相手の場にキーがある場合、追加でカードを１枚引き【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 대상이 없어도 쓸 수 있다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_KEY,nil):GetCount()>0 then
      Duel.Draw(tp,1)
      Duel.EnaCharge(tp,1)
    end
  end)
  c:RegisterEffect(e1)
end
