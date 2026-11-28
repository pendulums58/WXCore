-- WXK09-051 コードアート　Ｔ・Ｒ・Ｓ
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー1000以下のシグニ１体を対象とし、それをエナゾーンに置く。あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ１枚以上ある場合、代わりに対戦相手のパワー5000以下のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local p=(function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) and 5000 or 1000
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e1)
end
