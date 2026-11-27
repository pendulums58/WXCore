-- WX16-077 羅菌　ススカビ
-- 【出】対戦相手の場にある【ウィルス】１つを取り除く：あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
    if chk==0 then return #zones>0 end
    Duel.RemoveVirus(Duel.SelectZone(tp,zones))
  end)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e1)
end
