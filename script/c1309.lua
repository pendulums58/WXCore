-- WD20-009 具英の鋭針　＃コンパス＃
-- 【自】英知=７：このシグニがアタックしたとき、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 【常】英知=１０：このシグニが正面にアタックする場合、このシグニは正面に加えてその隣のシグニゾーン１つにアタックしてもよい。
-- 【起】《緑》《緑》《無》：対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(aux.EichiCon(7))
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
  -- [の間] 【常】 어택할 때 옆 존을 정하면 그 뒤 조건이 풀려도 그대로(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_ATTACK_NEIGHBOR)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(aux.EichiCon(10))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{G}{G}{C}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e4)
end
