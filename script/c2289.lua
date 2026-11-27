-- WX08-043 音階の左巧　ヘオン
-- 《クロスアイコン》《音階の右律　トオン》の左
-- 【クロス出】：あなたのデッキの上からカードを２枚公開する。その中から＜美巧＞のシグニ１枚をエナゾーンに置くか手札に加える。残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2275,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil),0,1):GetFirst()
    -- 예 = 에나 존, 아니오 = 패
    if x then if Duel.SelectYesNo(tp) then Duel.SendToEna(x) else Duel.SendToHand(x) end end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
