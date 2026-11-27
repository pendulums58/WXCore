-- WX08-057 爆砲　マイン
-- 【起】《ダウン》手札から《クロスアイコン》を持つシグニを１枚捨てる：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasCrossIcon() end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
