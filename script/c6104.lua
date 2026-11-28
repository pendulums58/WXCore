-- WXEX1-70 コードイート　セアブラ
-- 【常】：このシグニはアクセされているかぎり、【ランサー】を得る。
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetAcce()~=nil end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_ENA)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local h=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_ENA) then Duel.Acce(h,tc) end
  end)
  c:RegisterEffect(e2)
  -- [の間] 【常】
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_LANCER)
  e3:SetRange(LOCATION_ACCE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) and x:GetAcce()==e:GetHandler() end)
  c:RegisterEffect(e3)
end
