-- WXK03-003B 夢限　-Ｅ-
-- 【常】：あなたはキーを好きな枚数場に出すことができる。
-- 【自】：このルリグが《夢限　-Ｐ-》から《夢限　-Ｅ-》になったとき、あなたのルリグトラッシュからすべてのアーツをこのルリグの下に置く。
-- 【起】エクシード４：対戦相手のすべてのシグニをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「キーを好きな枚数」는 아직. 【自】「-P-から-E-になったとき」는 -P-의 처리에서
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetRange(LOCATION_LRIG)
  e1:SetExceedCost(4)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SIGNI,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
