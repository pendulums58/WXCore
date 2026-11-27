-- WX15-092 ＨＯＬＥ　ＯＵＴ
-- あなたのデッキの上からカードを４枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番下に置く。
-- （【トラップ】はシグニゾーン１つにつき１つまで裏向きで設置できる。対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
