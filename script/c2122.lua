-- WX05-065 羅原　Ｃｒ
-- 【常】：このシグニのパワーはあなたの場にある他の＜原子＞のシグニのレベル１につき＋1000される。（他にレベル２とレベル３のシグニがある場合、このシグニのパワーは＋5000される）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) local n=0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):Iter() do n=n+x:GetLevel() end return 1000*n end)
  c:RegisterEffect(e1)
end
