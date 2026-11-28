-- WXK05-005 獣群邁進
-- あなたのセンタールリグが＜ユヅキ＞でない場合、あなたの手札とエナゾーンとシグニゾーンにあるすべてのカードをデッキに加える。
-- あなたのトラッシュにあるすべてのカードをデッキに加えてシャッフルする。その後、カードを３枚引き、【エナチャージ４】をし、あなたのデッキの上からカードを５枚公開してその中から好きな枚数の緑のシグニを場に出し、残りをトラッシュに置く。この方法で場に出たシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    if not (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_YUZUKI) end)() then
      local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE,0,nil)
      if g:GetCount()>0 then Duel.SendToDeckShuffle(g,tp) end
    end
    Duel.SendToDeckShuffle(Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil),tp)
    Duel.Draw(tp,3)
    Duel.EnaCharge(tp,4)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for x in Duel.SelectCards(tp,g:Filter(function(y) return y:IsSigni() and y:IsColor(COLOR_GREEN) end,nil),0,3):Iter() do Duel.PutOnField(x,tp,true) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
