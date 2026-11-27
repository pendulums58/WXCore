-- WX04-043 羅石　黒曜
-- 【起】《赤》《赤》＜鉱石＞か＜宝石＞のシグニを合計３体場からトラッシュに置く：すべてのシグニをバニッシュする。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{R}{R}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=3 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,3,3),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(aux.BanishPowerTarget(12000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
