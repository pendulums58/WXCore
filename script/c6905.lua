-- WXK09-032 コードハート　Ｏ・Ｐ・Ａ
-- 【出】エナゾーンから共通する色を持つシグニ２枚をトラッシュに置く：この方法でトラッシュに置いたシグニのレベルの合計と同じレベルを持つ対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
-- 【起】《ターン１回》エナゾーンからシグニ２枚をトラッシュに置く：あなたのデッキからこの方法でトラッシュに置いたシグニのレベルの合計と同じレベルを持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「共通する色を持つ」
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    Duel.SetSelectCheck(function(sg) local c=nil for x in sg:Iter() do c=c and (c&x:GetColor()) or x:GetColor() end return c~=0 end)
    local sg=Duel.SelectCards(tp,g,2,2)
    local n=0
    for x in sg:Iter() do n=n+x:GetLevel() end
    e:SetLabel(n)
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local n=e:GetLabel()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    local sg=Duel.SelectCards(tp,g,2,2)
    local n=0
    for x in sg:Iter() do n=n+x:GetLevel() end
    e:SetLabel(n)
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local n=e:GetLabel()
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e9)
end
