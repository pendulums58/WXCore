-- WX14-052 コードメイズ　シンギョ
-- 【自】：対戦相手のシグニ１体がアタックしたとき、このシグニを他のシグニゾーンに配置してもよい。（すでにシグニのあるシグニゾーンには配置できない）
-- 【自】：場にあるこのシグニが効果によって他のシグニゾーンに移動したとき、ターン終了時まで、このシグニのパワーを＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(tp)) do
      if Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,tp,LOCATION_SIGNI,0,nil):GetCount()==0 then zones[#zones+1]=z end
    end
    if #zones==0 or not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
    local z=Duel.SelectZone(tp,zones)
    if z then Duel.SwapSigni(h,z) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_SIGNI_MOVED)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000) end  -- [まで]
  end)
  c:RegisterEffect(e2)
end
