-- WX12-025 羅星　アルケス
-- 【ガード】（このカードを手札から捨てることで、ルリグのアタックによるダメージを一度防ぐ）
-- 【常】：あなたのセンタールリグが＜サシェ＞でないかぎり、手札にあるこのシグニは【ガード】を失う。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 패에서
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_LOSE_GUARD)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return not (lc and lc:IsLrigType(LRIG_SASHE)) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
