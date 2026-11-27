-- WX04-030 トライ・シグナル
-- このスペルの使用コストはあなたの場にある＜迷宮＞のシグニ１体につき《白×1》減る。
-- 対戦相手のシグニ１体を対象とし、それを対戦相手のデッキに戻し、対戦相手は自分のデッキをシャッフルする。
-- ライフバースト：手札から＜迷宮＞のシグニ１枚を捨てる。そうした場合、対戦相手は対象の自分のシグニ１体をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 낸 뒤에 줄어도 더 내지 않는다(FAQ 1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{W}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckShuffle(tc,1-tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(1-tp,Card.IsSigni,1-tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 패는 비공개라 버리지 않아도 된다
  e2:SetOperation(function(e,tp)
    local g=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
