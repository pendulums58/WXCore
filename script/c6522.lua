-- WXK04-066 羅植　オバナ
-- 【出】エナゾーンから＜植物＞のシグニ１枚をトラッシュに置く：あなたのデッキから＜植物＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,1)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
