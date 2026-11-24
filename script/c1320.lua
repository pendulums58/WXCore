-- WD21-004 カーニバル　―ＰＡ―
-- 【出】《コインアイコン》：カードを２枚引く。その後、対戦相手はあなたの手札を１枚見ないで選び、あなたはそれを捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  -- 「見ないで選び」: 뒷면으로 고른다
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
