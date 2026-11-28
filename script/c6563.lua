-- WXK05-021 羅植姫　デンドロ
-- 【自】《ターン１回》：あなたの他のシグニ１体が開花したとき、対戦相手のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【起】《ターン１回》エナゾーンから＜植物＞のシグニ２枚をトラッシュに置く：あなたのデッキの上からカードを３枚見て、その中から＜植物＞のシグニを２枚まで公開し手札に加え、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。あなたのデッキの一番上を公開し、それが＜植物＞のシグニの場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BLOOM)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x~=e:GetHandler() and x:GetControler()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    Duel.SendToHand(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,nil),0,2)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if (function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end)(x) then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e9)
end
