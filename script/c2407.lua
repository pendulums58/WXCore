-- WX10-034 肆ノ遊姫　ベイゴマ
-- 【自】：このシグニがアタックしたとき、あなたの他のシグニを２体まで対象とし、それらをバニッシュしてもよい。その後、この効果でバニッシュしたシグニと同じ数だけエナゾーンからカードを対象とし、それらを手札に加える。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,0,2,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local n=Duel.Banish(g)
    if n>0 then
      local h=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,n,n,nil)
      if h:GetCount()>0 then Duel.SendToHand(h) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e2)
end
