-- WX07-014 クロス・スクランブル
-- このカードはあなたの場にクロス状態のシグニがある場合にしか使用できない。
-- スペル１つを対象とし、それの効果を打ち消す。その後、あなたはそれをトラッシュから、あなたの手札にあるかのようにコストを支払わずに限定条件を無視して使用してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  -- 打ち消して트래시에 놓인 뒤 써도 된다(FAQ 1·3). 打ち消されない 스펠이면 못 쓴다(FAQ 6)
  e1:SetOperation(function(e,tp)
    Duel.NegateSpell(false,true)
  end)
  c:RegisterEffect(e1)
end
