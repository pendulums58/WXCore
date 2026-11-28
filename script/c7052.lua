-- WXK10-078 幻怪　トレント
-- 【常】：あなたの右のシグニゾーンにある＜怪異＞のシグニのパワーを＋4000する。
-- 【常】：あなたの左のシグニゾーンにある＜怪異＞のシグニは【ランサー】を得る。
-- 【起】《ターン１回》《緑×0》：あなたの他のシグニ１体を対象とし、それとこのシグニの場所を入れ替える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 오른쪽(근사: 존 목록 다음 칸)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) local h=e:GetHandler() local z=h:GetZone() local zs=Duel.GetSigniZones(h:GetControler()) for i,k in ipairs(zs) do if k==z then return x:GetZone()==zs[i+1] and x:IsClass(0,RACE_KAII) end end return false end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 왼쪽
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LANCER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) local h=e:GetHandler() local z=h:GetZone() local zs=Duel.GetSigniZones(h:GetControler()) for i,k in ipairs(zs) do if k==z then return x:GetZone()==zs[i-1] and x:IsClass(0,RACE_KAII) end end return false end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SwapSigni(e:GetHandler(),tc)
    end
  end)
  c:RegisterEffect(e3)
end
