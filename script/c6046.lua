-- WXEX1-12 ミルルン・アマラ
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から＜原子＞のシグニ１枚とスペル１枚を手札に加え、残りをトラッシュに置く。
-- 【起】《ターン１回》手札から＜原子＞のシグニを２枚捨てる：あなたのデッキからカード１枚を探して手札に加え、デッキをシャッフルする。
-- 【起】《スペルカットインアイコン》《コインアイコン》：スペル１つを対象とし、それの効果を打ち消す。
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
    local p1=Duel.SelectCards(tp,g:Filter(aux.ClassFilter(0,RACE_GENSHI),nil),1,1)
    local p2=Duel.SelectCards(tp,g:Filter(function(x) return x:IsType(TYPE_SPELL) end,p1:GetFirst()),1,1)
    p1:Merge(p2)
    if p1:GetCount()>0 then Duel.SendToHand(p1) end
    local rest=g:Filter(function(x) return not p1:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(2,aux.ClassFilter(0,RACE_GENSHI)))
  e2:SetOperation(function(e,tp)
    local tc=aux.Search(tp,nil,1):GetFirst()
    if tc then Duel.SendToHand(tc) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_CUTIN)
  e3:SetCoinCost(1)
  e3:SetCondition(function() return Duel.GetCutinSpell()~=nil end)
  e3:SetOperation(function() Duel.NegateSpell() end)
  c:RegisterEffect(e3)
end
