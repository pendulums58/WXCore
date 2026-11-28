-- WXEX1-19 奈落の閻魔　ウリス
-- 【出】：あなたのトラッシュからカード１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》《コインアイコン》：あなたのトラッシュから、対象のカード１枚をエナゾーンに置き、対象のカード１枚を手札に加え、対象のカード１枚をデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local t1=Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local ex=Group.CreateGroup()
    if t1 then ex:AddCard(t1) end
    local t2=Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,ex):GetFirst()
    if t2 then ex:AddCard(t2) end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,ex)
  end)
  e2:SetOperation(function(e,tp)
    local tg=Duel.GetTargets()
    local arr={}
    for x in tg:Iter() do arr[#arr+1]=x end
    if arr[1] and arr[1]:IsRelateToEffect(e) then Duel.SendToEna(arr[1]) end
    if arr[2] and arr[2]:IsRelateToEffect(e) then Duel.SendToHand(arr[2]) end
    if arr[3] and arr[3]:IsRelateToEffect(e) then Duel.SendToDeckBottom(Group.CreateGroup(arr[3]),false) end
  end)
  c:RegisterEffect(e2)
end
