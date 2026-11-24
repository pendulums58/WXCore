-- WDK07-Y04 花影の巫女　ユキ
-- 【出】手札を１枚捨てる：《コインアイコン》を得る。
-- 【出】：あなたのデッキの上からカードを４枚見る。その中からカード１枚を【シード】としてあなたのシグニゾーンに出してもよい。残りをシャッフルしてデッキの一番下に置く。
-- （【シード】であるカードはシグニゾーン１つにつき１枚まで裏向きで置くことができ、開花することでシグニになる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local sc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if sc then Duel.SetSeed(sc,tp) end
    local rest=g:Filter(function(x) return x~=sc end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
