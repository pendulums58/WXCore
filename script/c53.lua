-- WX09-Re16 幻獣　ミャオ
-- 【常】：対戦相手の場にシグニが３体あるかぎり、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>=3 end)
  c:RegisterEffect(e1)
end
