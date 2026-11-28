-- SP26-003 カウントレス・バレット（「Lostorage incited WIXOSS 4」 初回特典）
-- このアーツの使用コストは、対戦相手の場にある【ウィルス】１つにつき《黒×2》減る。
-- 対戦相手のシグニを好きな数対象とし、ターン終了時まで、それらのパワーを合わせて－20000する。この効果では1000単位でしか数字を割り振ることができない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    local n=0
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then n=n+1 end end
    return Duel.ReduceCost(base,"{B}{B}",n)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,3,nil)
  end)
  -- 1000 단위로 나눈다. 파워보다 많이 줘도 된다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local left,n=20,g:GetCount()
    for x in g:Iter() do
      n=n-1
      local a=n==0 and left or Duel.AnnounceNumber(tp,0,left)
      left=left-a
      if a>0 then aux.AddPower(e,x,-1000*a) end  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
end
