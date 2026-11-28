-- WXK07-105 快刀乱炎
-- ベット―《コインアイコン》《コインアイコン》
-- あなたの手札から＜アーム＞のシグニ１枚を場に出す。あなたがベットしていた場合、追加であなたの手札から＜アーム＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp,eg)
    local f=function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end
    for i=1,(Duel.IsBet() and 2 or 1) do
      local g=Duel.GetMatchingGroup(f,tp,LOCATION_HAND,0,nil)
      if g:GetCount()==0 then break end
      Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp)
    end
  end)
  c:RegisterEffect(e1)
end
