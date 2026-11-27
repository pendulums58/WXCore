-- WX12-021 幻竜姫　＃スパザウス＃
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中からすべての＜龍獣＞のシグニをエナゾーンに置き、残りを好きな順番でデッキの一番上に置く。
-- 【起】《緑》《赤》《無》：対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。この能力は対戦相手のセンタールリグがレベル４以上の場合にしか使用できない。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。対戦相手は自分のエナゾーンのカードが７枚になるように、エナゾーンからカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local f=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,nil)
    if f:GetCount()>0 then Duel.SendToEna(f) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{G}{R}{C}")
  e2:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and lc:GetLevel()>=4 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(aux.BanishPowerTarget(10000))
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ENA,0,nil)
    local n=g:GetCount()-7
    if n>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,g,n,n),REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
