-- WX09-Re15 ＴＲＥＡＳＵＲＥ
-- 手札を好きな枚数捨て、捨てた枚数に１を加えた枚数のカードを引く。
-- ライフバースト：カードを２枚捨て、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local g=Duel.SelectCards(tp,h,0,h:GetCount())
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) or 0
    Duel.Draw(tp,n+1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.Discard(tp,2)
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e2)
end
