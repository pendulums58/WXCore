-- WX12-051 幻竜　＃ステゴケラス＃
-- 【出】：あなたのエナゾーンにあるカードが３枚以下の場合、あなたのデッキの一番上を公開する。それが＜龍獣＞のシグニの場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()<=3 end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e1)
end
