-- WX22-050 エンジェル・アウェイク
-- あなたのデッキの上からカードを３枚公開する。その中からそれぞれ共通する色を持たないように好きな枚数の＜天使＞のシグニを選ぶ。選んだ中から好きな枚数をあなたのエナゾーンに置き、好きな枚数を手札に加える。残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    Duel.SetSelectCheck(function(sg) local m=0 for x in sg:Iter() do if x:GetColor()&m~=0 then return false end m=m|x:GetColor() end return true end)
    local pick=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,nil),0,3)
    for x in pick:Iter() do if Duel.SelectYesNo(tp) then Duel.SendToEna(x) else Duel.SendToHand(x) end end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
