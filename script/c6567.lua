-- WXK05-025 貨英の変動　エフエックス
-- 【出】：カードを２枚引き、手札からカード２枚を好きな順番でデッキの一番下に置く。その後、対戦相手のシグニ１体を対象とし、それを凍結する。
-- 【起】《ターン１回》《青》デッキの下からカードを４枚トラッシュに置く：この方法でトラッシュに置かれたシグニのレベルの合計が１１以上の場合、対象の対戦相手の凍結状態のシグニ１体をバニッシュし、あなたのセンタールリグが＜リメンバ＞の場合、追加で対象の対戦相手の凍結状態のシグニ１体をバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし、対戦相手のすべてのシグニを凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(2,h:GetCount())
    if n>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,h,n,n)),false) end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{U}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDeckbottomGroup(tp,4)
    if chk==0 then return g:GetCount()>=4 end
    Duel.SendToTrash(g,REASON_COST)
    local n=0
    for x in g:Iter() do if x:IsSigni() then n=n+x:GetLevel() end end
    e:SetLabel(n)
  end)
  e2:SetOperation(function(e,tp,eg)
    if e:GetLabel()<11 then return end
    local n=(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_REMEMBER) end)() and 2 or 1
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,0,n,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(x) end
  end)
  c:RegisterEffect(e9)
end
