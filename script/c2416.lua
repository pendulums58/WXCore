-- WX10-045 ＣＯＯＬＩＮＧ　ＯＦＦ
-- このスペルの使用コストはあなたの場にある＜水獣＞のシグニ１体につき《無×1》減る。
-- 対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- ライフバースト：あなたのデッキから＜水獣＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{C}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,1)
  end)
  c:RegisterEffect(e2)
end
