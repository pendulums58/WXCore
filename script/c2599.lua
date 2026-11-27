-- WX13-019 緑弐ノ遊　スイングライド
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜遊具＞のシグニをあなたの手札と場からトラッシュに置く
-- 【自】：レゾナではないあなたのシグニ１体が対戦相手のライフクロス１枚をクラッシュしたとき、このシグニをアップする。
-- 【出】：あなたのデッキの上からカードを３枚公開する。その中から１枚を手札に加え、１枚をエナゾーンに置き、残りをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_YUGU),LOCATION_HAND+LOCATION_SZONE)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) local c=Duel.GetCrusher() return ep~=tp and c and c:GetControler()==tp and not c:IsType(TYPE_RESONA) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local a=Duel.SelectCards(tp,g,1,1)
    Duel.SendToHand(a)
    local b=Duel.SelectCards(tp,g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil),0,1)
    if b:GetCount()>0 then Duel.SendToEna(b) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
end
