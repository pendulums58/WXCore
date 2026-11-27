-- WX01-032 ＳＮＡＴＣＨＥＲ
-- 対戦相手は手札を２枚捨てる。その後、対戦相手の手札が０枚の場合、カードを１枚引く。
-- ライフバースト：対戦相手の手札を１枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 1장 이하면 있는 만큼(FAQ 1). 뽑는 것은 쓴 쪽(FAQ 3)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,2)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()==0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 「見ないで選び」: 뒷면으로 고른다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e2)
end
