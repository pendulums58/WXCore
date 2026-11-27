-- WX21-Re01 ゲット・ノスタルジア
-- このスペルの使用コストは対戦相手の場にある能力を持たないシグニ１体につき《白×1》減る。
-- あなたのデッキから＜迷宮＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{W}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:HasAbility() end,tp,0,LOCATION_SZONE,nil):GetCount()) end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,2)
  end)
  c:RegisterEffect(e1)
end
