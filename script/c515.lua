-- WD17-009 仙石の西猿　ゴクウ
-- 【ライズ】あなたの＜武勇＞のシグニ１体の上に置く
-- 【自】：このシグニがアタックしたとき、このシグニの正面のシグニ１体を対象とし、このシグニのパワーが15000以上の場合、それをバニッシュする。
-- 【起】《赤》：ターン終了時まで、このシグニのパワーを＋3000する。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。あなたの場に＜武勇＞のシグニがある場合、代わりにパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,aux.ClassFilter(0,RACE_BUYU))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local f=e:GetHandler():GetFrontCard()
    Duel.SelectTarget(tp,function(x) return x==f end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and e:GetHandler():GetPower()>=15000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{R}")
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local max=s.max(tp)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=max end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=s.max(tp) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
function s.max(tp) return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_BUYU),tp,LOCATION_SZONE,0,nil):GetCount()>0 and 15000 or 10000 end
