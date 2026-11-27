-- WX13-030 幻竜神姫　バハムート
-- 【常】：【アサシン】
-- 【常】：【ダブルクラッシュ】
-- ライフバースト：対戦相手のシグニをパワー合計が10000以下になるように好きな数対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(g) local n=0 for x in g:Iter() do n=n+x:GetPower() end return n<=10000 end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
