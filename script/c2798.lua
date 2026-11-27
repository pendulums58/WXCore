-- WX15-084 中罠　カトリ
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキの一番上を見る。あなたはそのカードか、あなたの手札１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。
-- （【トラップ】はシグニゾーン１つにつき１つまで裏向きで設置できる。対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if x then Duel.ConfirmCards(tp,Group.CreateGroup(x)) end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if x then g:AddCard(x) end
    local y=Duel.SelectCards(tp,g,0,1):GetFirst()
    if y then Duel.SetTrap(y,tp) end
  end)
  c:RegisterEffect(e1)
end
