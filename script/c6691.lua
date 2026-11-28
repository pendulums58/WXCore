-- WXK06-076 コードメイズ　ブルーモ
-- 【自】：対戦相手のシグニ１体がアタックしたとき、このシグニを他のシグニゾーンに配置してもよい。（すでにシグニのあるシグニゾーンには配置できない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(tp)) do if Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,tp,LOCATION_SZONE,0,nil):GetCount()==0 then zs[#zs+1]=z end end
    if #zs==0 or not Duel.SelectYesNo(tp) then return end
    local z=Duel.SelectZone(tp,zs)
    if z then Duel.MoveSigni(h,z) end
  end)
  c:RegisterEffect(e1)
end
