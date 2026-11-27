-- WX03-018 幻水　カレイラ
-- 【出】《青》ルリグデッキから青のアーツ１枚をルリグトラッシュに置く：カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_BLUE) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
