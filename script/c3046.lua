-- WX19-017 エクスクラメーション
-- アンコール －《コインアイコン》《コインアイコン》
-- あなたの手札から＜水獣＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
