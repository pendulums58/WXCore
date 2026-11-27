-- WX12-022 幻獣　ホーク
-- 【常】：このシグニはあなたの場にパワー10000以上のシグニがある場合にしか新たに場に出すことができない。
-- 【自】：このシグニがアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【自】《ターン１回》：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、《緑》《緑》《緑》《緑》《緑》を支払ってもよい。そうした場合、対戦相手にダメージを与える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=10000 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()==0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_CRUSHED)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e3:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{G}{G}{G}{G}{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{G}{G}{G}"),REASON_COST)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e3)
end
