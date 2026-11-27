-- WX02-037 ＳＰＲＡＳＨ
-- あなたの＜水獣＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、カードを２枚引く。
-- ライフバースト：カードを１枚引く。あなたの場に＜水獣＞のシグニがある場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 바니시하지 못하면 뽑지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
