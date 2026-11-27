-- WX02-040 着植
-- ターン終了時まで、あなたのすべての＜空獣＞と＜地獣＞と＜植物＞のシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- ライフバースト：次のあなたのターン、あなたのシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- [まで] 처리할 때 장에 있는 시그니만
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU) or x:IsClass(0,RACE_SHOKUBUTSU)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.GrantKeyword(e,tc,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    -- [の間] 다음 내 턴 동안 내 시그니 전부(나중에 나온 것도. FAQ 2). 그 턴의 끝에 사라진다
    local now,mine=Duel.GetTurnCount(),Duel.GetTurnPlayer()==tp
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_LANCER)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return x:IsSigni() end)
    e1:SetCondition(function() return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>now end)
    e1:SetReset(RESET_PHASE+PHASE_END,mine and 3 or 2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
