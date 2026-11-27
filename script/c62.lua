-- WX09-Re02 アイドル・ディフェンス
-- このターンに対戦相手がアーツかスペルを使用していた場合、このアーツの使用コストは《白×1》《無×4》になる。両方を使用していた場合、このアーツの使用コストは《白×0》になる。
-- 以下の２つから１つを選ぶ。
-- ①このターン、対戦相手のシグニアタックステップをスキップする。
-- ②このターン、対戦相手のルリグアタックステップをスキップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    local a,s=Duel.GetArtsUsedCount(1-tp)>0,Duel.GetSpellsUsedCount(1-tp)>0
    if a and s then return "" end
    if a or s then return "{W}{C}{C}{C}{C}" end
    return base
  end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(e:GetLabel()==0 and EFFECT_SKIP_SIGNI_ATTACK or EFFECT_SKIP_LRIG_ATTACK)
    e1:SetTargetRange(0,1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
