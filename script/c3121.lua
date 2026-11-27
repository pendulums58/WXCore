-- WX20-028 コードデリシャス　ビューフェ
-- 【常】：このシグニには好きな枚数の【アクセ】を付けることができる。
-- 【自】：このシグニがアタックしたとき、このシグニにカードが３枚以上アクセされている場合、このシグニに付いている【アクセ】と対戦相手のエナゾーンにあるカードと対戦相手のシグニをすべてトラッシュに置く。
-- 【出】：あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ライフバースト：あなたのデッキから《アクセアイコン》を持つカードを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「好きな枚数の【アクセ】」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local acc=Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil)
    if acc:GetCount()<3 then return end
    local g=acc
    g:Merge(Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil))
    g:Merge(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil))
    Duel.SendToTrash(g,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=aux.Search(tp,Card.HasAcceIcon,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
