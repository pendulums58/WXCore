-- WX17-075 コードイート　タルタル
-- 【自】：このシグニの正面にレベル２以下のシグニ１体が出たとき、あなたはそのシグニをバニッシュしてもよい。
-- 【起】《緑》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：このシグニの正面にこのシグニより低いレベルを持つシグニが出たとき、あなたはそれをバニッシュしてもよい。」を得る。
-- ライフバースト：対象のあなたのシグニ１体より低いレベルを持つ対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg)
    local h,x=e:GetHandler(),eg:GetFirst()
    return x:GetControler()~=tp and x:IsSigni() and x:GetZone()==Duel.GetFrontZone(h:GetZone()) and x:GetLevel()<=2
  end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1),"{G}")
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_ON_PLAY)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg)
    local h,x=e:GetHandler(),eg:GetFirst()
    return x:GetControler()~=tp and x:IsSigni() and x:GetZone()==Duel.GetFrontZone(h:GetZone()) and x:GetLevel()<e:GetHandler():GetLevel()
  end)
  g:SetOperation(function(e,tp,eg) local x=eg:GetFirst() if x:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) then Duel.Banish(x) end end)
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
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e3:SetOperation(function(e,tp)
    if s.a and s.b and s.b:IsRelateToEffect(e) and s.b:GetLevel()<s.a:GetLevel() then Duel.Banish(s.b) end
  end)
  c:RegisterEffect(e3)
end
