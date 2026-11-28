-- WXEX1-51 羅菌姫　ハショフ
-- 【常】：対戦相手の感染状態のシグニのパワーを－2000する。
-- 【常】：対戦相手は感染状態のシグニの【起】能力を使用できない。
-- 【起】《ターン１回》《黒》：対戦相手のシグニゾーン２つまでに【ウィルス】を１つずつ置く。
-- ライフバースト：対戦相手のシグニゾーン１つに【ウィルス】１つを置く。ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsInfected() end)
  e1:SetValue(-2000)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_DISABLE_ABILITY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,LOCATION_SZONE)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsInfected() end)
  e2:SetValue(ABILITY_IGNITION)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{K}")
  e3:SetOperation(function(e,tp)
    local used={}
    for i=1,2 do
      if i>1 and not Duel.SelectYesNo(tp) then break end
      local zs={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
        if not used[z] then zs[#zs+1]=z end
      end
      local z=Duel.SelectZone(tp,zs)
      if not z then break end
      used[z]=true
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
    if z then Duel.PlaceVirus(z) end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)
  c:RegisterEffect(e9)
end
