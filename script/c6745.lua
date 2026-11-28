-- WXK07-047 羅菌　カロテン
-- 【起】《ターン１回》《緑》あなたの場にある【チャーム】１枚をトラッシュに置く：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{G}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then g:AddCard(x:GetCharm()) end end
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
