-- WXK03-052 極装　ラーヴァテイン
-- 【出】手札から＜アーム＞のシグニを２枚捨てる：対象の対戦相手のシグニ１体をバニッシュする。そうした場合、対戦相手のエナゾーンから対象の【マルチエナ】を持つカード１枚をトラッシュに置く。（バニッシュするシグニとエナゾーンのカードを先に選ぶ。バニッシュできなかった場合はエナゾーンのカードをトラッシュに置くことができない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 바니시할 것과 에나 카드를 먼저 고른다(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(2,function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:HasKeyword(EFFECT_MULTI_ENA) end,tp,0,LOCATION_ENA,0,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local s1,en=nil,nil
    for x in Duel.GetTargets():Iter() do if x:IsLocation(LOCATION_SZONE) then s1=x else en=x end end
    if s1 and s1:IsRelateToEffect(e) and Duel.Banish(s1)>0 and en and en:IsRelateToEffect(e) then Duel.SendToTrash(en,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
