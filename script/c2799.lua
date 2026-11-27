-- WX15-086 小罠　ホイホイ
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキの一番上を見る。あなたはそのカードを【トラップ】としてあなたのシグニゾーンに設置してもよい。
-- （【トラップ】はシグニゾーン１つにつき１つまで裏向きで設置できる。対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if Duel.SelectYesNo(tp) then Duel.SetTrap(x,tp) end
  end)
  c:RegisterEffect(e1)
end
