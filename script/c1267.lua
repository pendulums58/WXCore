-- WD15-013 幻竜　フェニックス
-- 【自】：あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき、このシグニをトラッシュから場に出してもよい。
-- 【自】：このシグニがバニッシュされたとき、対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュしてもよい。
-- ライフバースト：あなたのトラッシュから＜龍獣＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(s.con)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetTarget(aux.BanishPowerTarget(10000))
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=10000 end
-- 「あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき」: 1장마다
function s.con(e,tp,eg,ep,ev,re,r,rp)
  local x=eg:GetFirst()
  return x:GetOwner()~=tp and x:IsPreviousLocation(LOCATION_ENA) and (r&REASON_EFFECT)~=0 and rp==tp
end
