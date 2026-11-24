-- WD18-001 メル＝アンジュ
-- 【出】《コインアイコン》：あなたのデッキから《アクセアイコン》を持つカードを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
-- 【起】《ターン１回》それぞれレベルの異なる＜調理＞のシグニ４枚をエナゾーンからトラッシュに置く：あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.HasAcceIcon,tp,LOCATION_MDECK,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_CHOURI),tp,LOCATION_ENA,0,nil)
    if chk==0 then return s.levels(g)>=4 end
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==4 and s.levels(sg)==4 end)
    Duel.SendToTrash(Duel.SelectCards(tp,g,4,4),REASON_COST)
  end)
  e2:SetOperation(function(e,tp) Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end)
  c:RegisterEffect(e2)
end
-- 서로 다른 레벨의 수
function s.levels(g)
  local lv,n={},0
  for x in g:Iter() do
    if not lv[x:GetLevel()] then
      lv[x:GetLevel()]=true
      n=n+1
    end
  end
  return n
end
