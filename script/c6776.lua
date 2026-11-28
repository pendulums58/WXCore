-- WXK07-078 羅菌　ビタミンK
-- 【出】：あなたのデッキの一番上のカードをこのシグニの【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if x and h:IsLocation(LOCATION_SZONE) and not h:GetCharm() then Duel.Charm(x,h) end
  end)
  c:RegisterEffect(e1)
end
