-- WX06-CB02 コードアート　Ｔ・Ａ・Ｐ
-- 【常】：対戦相手の手札が０枚であるかぎり、このシグニの基本パワーは10000になる。
-- 【出】：対戦相手の手札を見る。
-- ライフバースト：対戦相手の手札を見て１枚選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_HAND,nil):GetCount()==0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
  end)
  c:RegisterEffect(e2)
end
