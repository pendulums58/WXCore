-- WX14-041 幻竜　＃コブラ＃
-- 【出】手札から赤の＜龍獣＞のシグニを１枚捨てる：対戦相手は自分のエナゾーンからカード１枚を対象とし、対戦相手のエナゾーンにカードが３枚以上ある場合、それをトラッシュに置く。
-- 【出】手札から緑の＜龍獣＞のシグニを１枚捨てる：あなたのデッキの上からカードを２枚公開する。その中からすべての＜龍獣＞のシグニをエナゾーンに置き、残りを好きな順番でデッキの一番上に置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_RED) end))
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()<3 then return end
    local x=Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_GREEN) end))
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local f=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,nil)
    if f:GetCount()>0 then Duel.SendToEna(f) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
