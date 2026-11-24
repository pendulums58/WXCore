-- WDK03-001 四型絆娘　翠子
-- 【起】《コインアイコン》：あなたのルリグデッキから《異体同心　華代》１枚を場に出す。
-- 【起】《ターン１回》《コインアイコン》：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCoinCost(1)
  -- 루리그 덱은 비공개라 내지 않아도 된다
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsCardName(1021) end,tp,LOCATION_LDECK,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.PutKey(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e2)
end
