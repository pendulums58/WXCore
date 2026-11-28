-- WXK07-055-CB 羅星 人生さんR
-- 【自】：このシグニがアタックしたとき、あなたの場に《羅星 人生さんＢ》がある場合、あなたのデッキの上からカードを５枚見る。その中から１枚をトラッシュに置き、残りを好きな順番でデッキの一番上に戻す。
-- 【出】：あなたのデッキの上からカードを２枚見る。その中から１枚をトラッシュに置き、残りをデッキの一番上に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6752) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>1 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>1 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
