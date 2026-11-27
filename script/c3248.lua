-- WX22-026 図画の工作　*カミネンド*
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から白の＜美巧＞のシグニ１枚と緑の＜美巧＞のシグニ１枚を手札に加え、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：あなたのデッキから＜美巧＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
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
    local a=Duel.SelectCards(tp,g:Filter(function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(c) and c:IsColor(COLOR_WHITE) end,nil),0,1)
    a:Merge(Duel.SelectCards(tp,g:Filter(function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(c) and c:IsColor(COLOR_GREEN) and not a:IsContains(c) end,nil),0,1))
    if a:GetCount()>0 then Duel.SendToHand(a) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,1)
  end)
  c:RegisterEffect(e2)
end
