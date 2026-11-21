-- WDK09-008 フォルテ・バレーノ
-- カードを２枚引く。対戦相手の場にキーがある場合、対戦相手は手札を２枚捨てる。(키가 몇 장이든 2장. FAQ 1)
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_KEY,nil):GetCount()>0 then
      Duel.SendToTrash(Duel.SelectDiscard(1-tp,2,2),REASON_EFFECT+REASON_DISCARD)
    end
  end)
  c:RegisterEffect(e1)
end
