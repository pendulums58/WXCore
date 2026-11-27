-- WX16-016 アウト・ダスト
-- 各プレイヤーは、場にある最も高いレベルを持つセンタールリグのレベルの数だけ手札を捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local n=0
    for p=0,1 do local lc=Duel.GetMatchingGroup(nil,p,LOCATION_LRIG,0,nil):GetFirst() if lc and lc:GetLevel()>n then n=lc:GetLevel() end end
    local p=Duel.GetTurnPlayer()
    aux.Discard(p,n)
    aux.Discard(1-p,n)
  end)
  c:RegisterEffect(e1)
end
