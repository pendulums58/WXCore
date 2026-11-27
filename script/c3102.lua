-- WX20-002 メル＝スピリタス
-- 【出】：あなたのトラッシュからそれぞれ名前の異なる《アクセアイコン》を持つシグニを３枚まで対象とし、それらをエナゾーンに置く。
-- 【起】《ターン１回》《アタックフェイズアイコン》《緑×0》：あなたのエナゾーンから対象の《アクセアイコン》を持つカード１枚を対象のあなたのシグニ１体の【アクセ】にする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》：あなたのエナゾーンから＜調理＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasAcceIcon() end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local seen,out={},Group.CreateGroup()
    for x in g:Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true out:AddCard(x) end end  -- 이름이 다른 것만
    if out:GetCount()>0 then Duel.SendToEna(out) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.HasAcceIcon,tp,LOCATION_ENA,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
  end)
  e2:SetOperation(function(e,tp)
    if s.a and s.b and s.a:IsRelateToEffect(e) and s.b:IsRelateToEffect(e) then Duel.Acce(s.a,s.b) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(1)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
