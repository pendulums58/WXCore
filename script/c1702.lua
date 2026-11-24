-- WDK10-015 幻竜　コスド
-- 【自】：このシグニがアタックしたとき、手札から＜龍獣＞のシグニを１枚捨ててもよい。その後、パワーがこの方法で捨てたシグニのパワーの半分以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectDiscard(tp,0,1,s.ryu):GetFirst()
    if not x or Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)==0 then return end
    local n=x:GetPower()
    local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetPower()*2<=n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
