-- WD06-013 幻水　チョウアン
-- 【出】ライフクロス１枚をトラッシュに置く：あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트로 트래시에 놓는 것은 크러시가 아니라 버스트는 없다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLifetopGroup(tp,1):GetCount()>0 end
    Duel.SendToTrash(Duel.GetLifetopGroup(tp,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp) Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end)
  c:RegisterEffect(e1)
end
