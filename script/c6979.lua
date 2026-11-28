-- WXK10-005 紫幹翠葉
-- このターン、次にあなたがダメージを受ける場合、代わりにダメージを受けない。このターン、対戦相手のシグニのパワーが効果によって＋（プラス）される場合、代わりに－（マイナス）される。シグニゾーン１つを指定する。このターン、指定されたシグニゾーンにあるシグニのパワーを＋10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INVERT_PLUS)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(tp)) do zs[#zs+1]=z end
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do zs[#zs+1]=z end
    local z=Duel.SelectZone(tp,zs)
    if not z then return end
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_POWER)
    e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
    e3:SetTarget(function(e,x) return x:GetZone()==z end)
    e3:SetValue(10000)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
  end)
  c:RegisterEffect(e1)
end
