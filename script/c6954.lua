-- WXK09-081 コードアート　Ｓ・Ｄ・Ｉ
-- 【出】：対戦相手のレベル１以下のシグニ１体を対象とし、あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ１枚以上ある場合、それをエナゾーンに置く。それぞれ２枚以上ある場合、代わりに対戦相手のレベル３以下のシグニ１体を対象とし、それをエナゾーンに置く。
-- 【自】：このカードがトラッシュからエナゾーンに置かれたとき、あなたの＜電機＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「それぞれ２枚以上ある場合、代わりに…」(근사: 레벨 3 이하)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if not (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) then return end
    local lv=(function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<2 then return false end end return true end)(tp) and 3 or 1
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_ENA)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_TRASH) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,5000)
    end
  end)
  c:RegisterEffect(e2)
end
