-- WXEX1-08 真心の記憶　リル
-- 【自】《ターン１回》：あなたが《コインアイコン》をベットしたとき、《コインアイコン》を得る。
-- 【自】《ターン１回》：《ライズアイコン》を持つあなたのシグニ１体が場に出たとき、あなたのデッキの一番上を公開する。それが＜武勇＞のシグニの場合、それを手札に加える。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》《コインアイコン》：《ライズアイコン》を持たないすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and Duel.IsBet() end)
  e1:SetOperation(function(e,tp) Duel.AddCoin(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:IsSigni() and x:GetControler()==tp and x:HasRiseIcon() end,nil):GetCount()>0
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsClass(0,RACE_BUYU) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCoinCost(3)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:HasRiseIcon() end,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
