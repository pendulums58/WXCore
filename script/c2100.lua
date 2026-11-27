-- WX05-038 ＳＰＩＲＡＬ
-- あなたの場に《幻水姫　スパイラル・カーミラ》がある場合、このカードの使用コストは《青×1》になる。
-- 対戦相手のシグニ１体を対象とし、あなたの手札が４枚以上ある場合、それをバニッシュする。
-- ライフバースト：カードを１枚引く。その後、手札から《幻水姫　スパイラル・カーミラ》１枚を公開してもよい。そうした場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.GetMatchingGroup(function(x) return x:IsCardName(1915) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and "{U}" or base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=4 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if aux.RevealFromHand(tp,function(x) return x:IsCardName(1915) end,1):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
