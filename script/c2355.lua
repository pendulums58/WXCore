-- WX09-031 羅植　キク
-- 【出】：あなたの場に＜植物＞のシグニが３体ある場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：あなたのデッキから＜植物＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end,1)
  end)
  c:RegisterEffect(e2)
end
