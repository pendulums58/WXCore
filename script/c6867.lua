-- WXK08-081 轟書　コウテ
-- 【出】：あなたのデッキの上からカードを２枚このシグニの下に置く。
-- （シグニの下に置かれるカードは表向きである）
-- （コストのない【出】能力は発動しないことを選べない。デッキが１枚の場合それをこのシグニの下に置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local g=Duel.GetDecktopGroup(tp,2)
    if h:IsLocation(LOCATION_SZONE) and g:GetCount()>0 then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
end
