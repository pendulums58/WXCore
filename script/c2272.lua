-- WX08-026 絢爛の轢断
-- このスペルの使用コストはあなたのライフクロス１枚につき《赤×1》増え、あなたの場にある＜鉱石＞か＜宝石＞のシグニ１体につき《赤×1》減る。
-- 対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュし、対戦相手のライフクロス１枚をクラッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、手札から＜鉱石＞か＜宝石＞のシグニを１枚捨てる。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base..string.rep("{R}",Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()),"{R}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetTarget(aux.BanishPowerTarget(12000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
