-- WD15-012 幻竜姫　ムシュフシュ
-- 【常】：このシグニはパワーが20000以上であるかぎり、【ダブルクラッシュ】と「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- 【自】：あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき、ターン終了時まで、このシグニのパワーを＋4000する。
-- 【起】《赤》《赤》《赤》：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのデッキの一番上を公開する。それが＜龍獣＞のシグニの場合、カードを２枚引く。それが＜龍獣＞のシグニではない場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  local d=Effect.CreateEffect(c)
  d:SetType(EFFECT_TYPE_SINGLE)
  d:SetCode(EFFECT_DOUBLE_CRUSH)
  -- [の間] 【常】 파워가 20000 이상인 동안 둘 다 얻는다
  for _,ab in ipairs({d,g}) do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_GRANT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return x==e:GetHandler() and x:GetPower()>=20000 end)
    e1:SetLabelObject(ab)
    c:RegisterEffect(e1)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.con)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,4000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{R}{R}{R}")
  e3:SetTarget(aux.BanishPowerTarget(12000))
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local tg=Duel.GetDecktopGroup(tp,1)
    local tc=tg:GetFirst()
    if not tc then return end
    Duel.RevealCards(tg)
    Duel.Draw(tp,tc:IsSigni() and tc:IsClass(0,RACE_RYUJU) and 2 or 1)
  end)
  c:RegisterEffect(e4)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=12000 end
-- 「あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき」: 1장마다
function s.con(e,tp,eg,ep,ev,re,r,rp)
  local x=eg:GetFirst()
  return x:GetOwner()~=tp and x:IsPreviousLocation(LOCATION_ENA) and (r&REASON_EFFECT)~=0 and rp==tp
end
