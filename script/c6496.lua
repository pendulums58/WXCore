-- WXK04-040 羅植　ボタン
-- 【常】：あなたのエナゾーンに＜植物＞のシグニが３枚以上あるかぎり、このシグニのパワーは＋2000される。
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンに＜植物＞のシグニが５種類以上ある場合、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,e:GetHandlerPlayer(),LOCATION_ENA,0,nil):GetCount()>=3 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if (function() local t,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil):Iter() do if not t[x:GetCode()] then t[x:GetCode()]=true n=n+1 end end return n end)()>=5 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
