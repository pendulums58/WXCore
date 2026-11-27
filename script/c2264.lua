-- WX08-018 恐悦至極
-- このカードはあなたの場にクロス状態のシグニがある場合にしか使用できない。
-- ターン終了時まで、あなたのすべての＜美巧＞のシグニは「【常】：バニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.GrantKeyword(e,tc,EFFECT_CANNOT_BANISH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
