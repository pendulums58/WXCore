-- WX04-049 幻獣　シエンコ
-- 【常】：あなたの場に他の＜空獣＞か＜地獣＞のシグニがあるかぎり、このシグニの基本レベルは２になる。（このシグニは場に出るまでレベル３であり、例えばあなたのセンタールリグのレベルが２の場合、場に出すことはできない）
-- 【起】《緑》《緑》：ターン終了時まで、あなたのすべてのシグニのパワーを２倍にする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 장에 나온 뒤에만(FAQ 4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CHANGE_LEVEL)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 end)
  e1:SetValue(2)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{G}{G}")
  -- [まで] 처리할 때의 파워만큼 더한다. 두 번이면 4배(FAQ 1·2)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,tc:GetPower()) end
  end)
  c:RegisterEffect(e2)
end
