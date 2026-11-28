-- WXK04-008 花霞の巫女　ユキ
-- 【出】：あなたのデッキの上からカードを４枚見る。その中からカード１枚を【シード】としてあなたのシグニゾーンに出してもよい。残りをシャッフルしてデッキの一番下に置く。
-- （【シード】であるカードはシグニゾーン１つにつき１枚まで裏向きで置くことができ、開花することでシグニになる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g,0,1):Iter() do Duel.SetSeed(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
