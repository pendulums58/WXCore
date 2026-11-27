-- WX15-094 伝英の数式　#パスカル#
-- 【常】：あなたの場に＜英知＞のシグニが３体あるかぎり、このシグニは、このシグニの正面の１つ隣の対戦相手のシグニゾーンにもアタックできる。
-- （シグニゾーンにアタックした場合、対戦相手にダメージを与えない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ATTACK_ZONE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end)
  e1:SetValue(1)
  c:RegisterEffect(e1)
end
