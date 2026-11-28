-- WXK07-045 羅菌　マンガーン
-- 【出】あなたの場にある【チャーム】１枚をトラッシュに置く：【エナチャージ１】
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then g:AddCard(x:GetCharm()) end end
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
