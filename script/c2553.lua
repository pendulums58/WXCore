-- WX12-027 笑顔の春姫　サホヒメ
-- 【出】：あなたのトラッシュに＜天使＞のシグニが５種類以上ある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local seen,n={},0
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_TRASH,0,nil):Iter() do
      if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end
    end
    if n>=5 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
