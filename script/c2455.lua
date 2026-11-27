-- WX10-093 破戒の韋駄　スカンダ
-- 【出】：あなたのデッキの一番上のカードをこのシグニの【チャーム】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if top and h:IsLocation(LOCATION_SZONE) and not h:GetCharm() then Duel.Charm(top,h) end
  end)
  c:RegisterEffect(e1)
end
