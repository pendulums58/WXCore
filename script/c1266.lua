-- WD15-011 幻竜姫　オロチ
-- 【常】：対戦相手のエナゾーンにあるカードが４枚以下であるかぎり、このシグニは【ダブルクラッシュ】を得る。
-- 【自】：このシグニがアタックしたとき、対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。
-- ライフバースト：対戦相手のエナゾーンから【マルチエナ】を持つ対象のカード１枚をトラッシュに置き、対象の対戦相手のパワー8000以下のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()<=4 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  -- 【マルチエナ】가 없어도 바니시한다(FAQ 2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:HasKeyword(EFFECT_MULTI_ENA) end,tp,0,LOCATION_ENA,1,1,nil)
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_ENA) then Duel.SendToTrash(tc,REASON_EFFECT)
        elseif s.filter(tc) then Duel.Banish(tc) end
      end
    end
  end)
  c:RegisterEffect(e3)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=8000 end
