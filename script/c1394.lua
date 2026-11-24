-- WD23-038-A 小罠　ブラクラ
-- 【出】：あなたの場に【トラップ】がない場合、あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番下に置く。
-- （【トラップ】はシグニゾーン１つにつき１つまで裏向きで設置できる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil):GetCount()>0 then return end
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.SetTrap(tc,tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
