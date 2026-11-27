-- WX13-013 三焼揃踏
-- 同じパワーを持つシグニ３体を対象とし、それらをバニッシュする。
-- （自分のシグニを含んでもよい。合計２体以下のシグニに使用することはできない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- 같은 파워 3체(자기 시그니도)
    Duel.SetSelectCheck(function(g)
      if g:GetCount()~=3 then return false end
      local p
      for x in g:Iter() do
        if p and x:GetPower()~=p then return false end
        p=x:GetPower()
      end
      return true
    end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,3,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
