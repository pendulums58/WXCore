-- SP01-001 満月の巫女　タマ（「selector infected WIXOSS」 BOX1 初回限定特典）
-- 【常】：あなたの場に《甲冑　ローメイル》があるかぎり、あなたのシグニのパワーを＋2000する
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 《甲冑　ローメイル》이 여러 체여도 ＋2000(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCardName(410) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
end
