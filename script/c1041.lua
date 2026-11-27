-- WX20-021 バイ・ザ・ウェイ
-- このアーツは対戦相手のターンにしか使用できない。
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手の手札が７枚以上ある場合、あなたは対戦相手の手札を４枚見ないで選び、捨てさせる。
-- ②対戦相手は自分のエナゾーンからカード５枚を対象とし、対戦相手のエナゾーンにカードが１０枚以上ある場合、それらをトラッシュに置く。
-- ③あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil) if h:GetCount()>=7 then Duel.SendToTrash(Duel.SelectCards(tp,h,4,4),REASON_EFFECT+REASON_DISCARD) end end
    if m&2~=0 then
      local g=Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,5,5,nil)
      if Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()>=10 and g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
    if m&4~=0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
