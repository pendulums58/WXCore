-- WX08-030 滅精
-- このスペルの使用コストはあなたの場にある＜美巧＞のシグニ１体につき《緑×1》減り、あなたのエナゾーンにある＜美巧＞のシグニ１枚につき《白×1》減る。（コストはその増減が決まった後で支払う）
-- 対戦相手のすべてのシグニを手札に戻す。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    base=Duel.ReduceCost(base,"{G}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_SZONE,0,nil):GetCount())
    return Duel.ReduceCost(base,"{W}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_ENA,0,nil):GetCount())
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e2)
end
