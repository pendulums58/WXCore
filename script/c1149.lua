-- WD06-015 幻水　ウナ
-- 【出】：あなたのライフクロスの一番上を見る。
local s,id=GetID()
function s.initial_effect(c)
  -- 본 사람만 안다(FAQ 1). 그대로 두므로 「加えられた」가 아니다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.ConfirmCards(tp,Duel.GetLifetopGroup(tp,1)) end)
  c:RegisterEffect(e1)
end
