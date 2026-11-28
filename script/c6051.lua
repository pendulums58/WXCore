-- WXEX1-17 メル＝ジントニック
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から＜調理＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《ターン１回》《コインアイコン》：あなたのデッキから《アクセアイコン》を持つシグニを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local n=aux.RevealCount(tp,2)
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local pick=Duel.SelectCards(tp,g:Filter(aux.ClassFilter(0,RACE_CHOURI),nil),0,2)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:HasAcceIcon() end,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
