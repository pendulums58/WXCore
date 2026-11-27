-- WX16-074 コードイート　メーシロ
-- 【起】《緑×0》：このカードをエナゾーンからあなたのシグニ１体の【アクセ】にする。
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：このシグニがバニッシュされたとき、カードを１枚引く。」を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_BANISHED)
  g:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  -- [の間] 【常】 이것이 붙은 ＜調理＞ 시그니가 얻는다
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_ACCE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
