-- WX07-021 アトラク・パニッシュ
-- 対象の好きな数のあなたの場にある【チャーム】をトラッシュに置く。ターン終了時まで、対象の対戦相手のシグニ１体のパワーをこの方法でトラッシュに置いた【チャーム】１枚につき－8000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local cg=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then cg:AddCard(x:GetCharm()) end
    end
    if cg:GetCount()>0 then Duel.SelectTarget(tp,function(x) return cg:IsContains(x) end,tp,LOCATION_SZONE,0,0,cg:GetCount(),nil) end
    s.t=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    local n=0
    for x in Duel.GetTargets():Iter() do
      if x~=s.t and x:IsRelateToEffect(e) and Duel.SendToTrash(x,REASON_EFFECT)>0 then n=n+1 end
    end
    -- [まで] ターン終了時まで
    if n>0 and s.t and s.t:IsRelateToEffect(e) then aux.AddPower(e,s.t,-8000*n) end
  end)
  c:RegisterEffect(e1)
end
