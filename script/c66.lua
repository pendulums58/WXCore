-- WX12-Re09 大剣　デュランダ
-- 【常】：あなたの場にあるシグニ３体がそれぞれ共通する色を持たないかぎり、このシグニの基本パワーは15000になり、対戦相手の効果を受けない。 （無色は色に含まれないので、場のシグニが白、無色、無色の場合、この能力は発動する）
-- ライフバースト：あなたのデッキからレベル３以下のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 3체가 서로 색을 공유하지 않을 때(무색은 색이 아니다. FAQ 2)
  aux.BasePower(c,15000,function(e) local g=Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil) if g:GetCount()~=3 then return false end local t={} for x in g:Iter() do t[#t+1]=x:GetColor() end return t[1]&t[2]==0 and t[1]&t[3]==0 and t[2]&t[3]==0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local g=Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil) if g:GetCount()~=3 then return false end local t={} for x in g:Iter() do t[#t+1]=x:GetColor() end return t[1]&t[2]==0 and t[1]&t[3]==0 and t[2]&t[3]==0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,1)
  end)
  c:RegisterEffect(e2)
end
