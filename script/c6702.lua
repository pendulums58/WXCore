-- WXK06-087 幻竜　ベビドラ
-- 【常】：あなたのトラッシュにカードが３枚以上あるかぎり、このシグニのパワーは＋3000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=3 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
end
