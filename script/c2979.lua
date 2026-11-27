-- WX18-019 奮闘努力
-- アンコール －《コインアイコン》《コインアイコン》
-- （アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのデッキからカードを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
