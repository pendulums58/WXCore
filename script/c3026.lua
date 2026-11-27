-- WX18-076 コードイート　ミカジャ
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、このシグニの正面にあったシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_BANISHED)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  g:SetOperation(function(e,tp)
    local f=Duel.GetFrontZone(e:GetHandler():GetPreviousZone())
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetZone()==f end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
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
