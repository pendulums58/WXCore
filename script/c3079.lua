-- WX19-059 大罠　ブーブー
-- 【トラップアイコン】：カードを２枚引く。
-- （対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
-- ライフバースト：カードを１枚引き、手札１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local x=Duel.SelectCards(tp,h,0,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
  end)
  c:RegisterEffect(e2)
end
