-- PR-474 ラッキー・パンチ（コロコロアニキ2020年夏号 付録）
-- あなたのライフクロスの一番上を見る。それがシグニの場合、そのシグニを場に出してもよい。それがスペルの場合、そのスペルを手札にあるかのようにコストを支払わずに使用してもよい。（限定条件は無視しない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 한정 조건은 지킨다
  e1:SetOperation(function(e,tp)
    local x=Duel.GetLifetopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if x:IsSigni() then
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
    elseif x:IsType(TYPE_SPELL) then
      if Duel.SelectYesNo(tp) then Duel.UseFree(x,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
