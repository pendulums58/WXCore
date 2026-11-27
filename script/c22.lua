-- WX09-Re20 墓守の小悪　アルマ
-- 【常】：あなたのトラッシュにカードが５枚以上あるかぎり、このシグニのパワーは＋2000される。
-- 【常】：あなたの場にレベル４の＜ウリス＞がいる場合、このシグニの基本パワーは10000になる。
-- （両方の条件を満たしている場合、このシグニのパワーは12000となる）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘(둘 다면 12000)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  aux.BasePower(c,10000,function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()==4 and lc:IsLrigType(LRIG_URITH) end)
end
