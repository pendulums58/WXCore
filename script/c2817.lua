-- WX15-105 コードイート　トロチー
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【常】：このシグニは対戦相手のスペルの効果を受けない。」を得る。
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE)
  g:SetCode(EFFECT_IMMUNE)
  g:SetRange(LOCATION_SZONE)
  g:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_SPELL) end)
  -- [の間] 【常】 이것이 붙은 ＜調理＞ 시그니가 얻는다
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_ACCE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
end
