-- PR-468 炎のタマ（コロコロアニキ2019年冬号 付録）
-- このターンに対戦相手がスペルを使用していた場合、このアーツの使用コストは使用されたスペル１枚につき《赤×1》《無×1》減る。
-- このターンに対戦相手がアーツを使用していた場合、このアーツの使用コストは《赤×3》《無×3》減る。
-- このターン、あなたはゲームに敗北しない。このカードをゲームから除外する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「敗北しない」가 우선한다(FAQ 1). 쓸 때 제외한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_LOSE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    Duel.Exclude(e:GetHandler())
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base)
    if Duel.GetArtsUsedCount(1-tp)>0 then
      base=Duel.ReduceCost(Duel.ReduceCost(base,"{R}",3),"{C}",3)
    else
      local n=Duel.GetSpellsUsedCount(1-tp)
      base=Duel.ReduceCost(Duel.ReduceCost(base,"{R}",n),"{C}",n)
    end
    return base
  end)
end
