-- WD15-006 隠忍火蝶
-- このカードはあなたがこのターンにアーツを使用していた場合、使用できない。
-- このアーツの使用コストはあなたのセンタールリグのレベル１につき《赤×1》減る。
-- ターン終了時まで、あなたのすべての＜龍獣＞のシグニは【アサシン】を得る。このターン、あなたはアーツを使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetArtsUsedCount(tp)==0 end)
  aux.SetCostBy(e1,s.cost)
  e1:SetOperation(function(e,tp)
    -- [まで] 쓴 때 장에 있는 것만(FAQ 2)
    for tc in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_SZONE,0,nil):Iter() do
      aux.GrantKeyword(e,tc,EFFECT_ASSASSIN)
    end
    -- [の間] 「このターン」
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_USE_ARTS)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
end
function s.cost(e,tp,base)
  local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  return Duel.ReduceCost(base,"{R}",lc and lc:GetLevel() or 0)
end
