-- WXK09-016 コード・ピルルク　Ｖ
-- 【出】：あなたのルリグデッキに《改造素材》１枚を加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    Duel.AddCraft(6974,tp)
  end)
  c:RegisterEffect(e1)
end
