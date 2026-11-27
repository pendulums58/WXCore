-- WX19-001 炎・タマヨリヒメ・伍改
-- 【常】：対戦相手は、手札から《ガードアイコン》を持つカードを追加で１枚捨てないかぎり【ガード】ができない。
-- 【起】《ターン２回》エクシード１：あなたのデッキから＜アーム＞か＜ウェポン＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：手札から《アーク・オーラ》を１枚捨てる。そうした場合、対戦相手のセンタールリグとすべてのシグニをダウンし、あなたのエナゾーンからすべてのカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「《ガードアイコン》を追加で１枚捨てないかぎり【ガード】ができない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(2)
  e1:SetExceedCost(1)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCoinCost(2)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsCardName(162) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local d=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG+LOCATION_SZONE,nil)
    for x in d:Iter() do if x:IsSigni() or x:IsType(TYPE_LRIG) then Duel.Down(x) end end
    local en=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if en:GetCount()>0 then Duel.SendToTrash(en,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
