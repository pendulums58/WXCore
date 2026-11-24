-- WD18-015 コードイート　マヨ
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニのパワーを＋2000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  -- [の間] 【常】 붙어 있는 동안, 붙은 시그니가 ＜調理＞이면
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_ACCE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and x:IsClass(0,RACE_CHOURI) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
