-- WXK07-084 羅星　ヘリックス
-- 【常】：あなたの場にあるシグニのレベルの合計が対戦相手の場にあるシグニのレベルの合計以下であるかぎり、このシグニのパワーは＋5000され、このシグニは「【常】：対戦相手の効果によってバニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)<=(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(1-tp) end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
  local e11=Effect.CreateEffect(c)
  e11:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 상대 효과로 바니시되지 않는다
  e11:SetCode(EFFECT_BANISH_IMMUNE)
  e11:SetRange(LOCATION_SZONE)
  e11:SetCondition(function(e) local tp=e:GetHandlerPlayer() return (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)<=(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(1-tp) end)
  e11:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e11)
end
