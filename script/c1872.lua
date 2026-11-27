-- WX01-069 爆砲　ランチャン
-- 【起】《ダウン》手札を１枚捨てる：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>0 end
    Duel.Down(e:GetHandler())
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
