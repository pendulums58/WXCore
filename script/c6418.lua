-- WXK03-044 油蛙の忍者　ジライヤ
-- 【出】：あなたのトラッシュが１５枚の場合、カードを１枚引き、【エナチャージ１】をし、あなたのデッキの上からカードを３枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 정확히 15장(FAQ 2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()==15 end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()==0 then return end
    Duel.EnaCharge(tp,1)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
