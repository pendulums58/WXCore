-- WXK04-028 紅蓮の使い魔　アカズキン
-- 【常】：このシグニは血晶武装状態であるかぎり、【ダブルクラッシュ】を得る。
-- 【自】《ターン１回》：あなたが【エナチャージ】をしたとき、【エナチャージ１】をする。
-- 【自】《ターン１回》：このシグニが対戦相手のライフクロスをクラッシュしたとき、《赤》《赤》を支払ってもよい。そうした場合、対戦相手にダメージを与える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_ENA)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) for x in eg:Iter() do if x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_MDECK) and rp==tp then return true end end return false end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_CRUSHED)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e3:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(aux.BanishOp)
  c:RegisterEffect(e9)
end
