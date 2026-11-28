-- WXEX1-09 カーニバル　－ＱＮ－
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中からレベル４のシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》：対戦相手の、場かエナゾーンからレベル１のシグニ１枚を対象とし、それをトラッシュに置く。レベル２、レベル３、レベル４、レベル５についても同様に行う。
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
    local pick=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsLevelBetween(4,4) end,nil),0,2)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCoinCost(4)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    for lv=1,5 do
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE+LOCATION_ENA,1,1,nil)
    end
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
