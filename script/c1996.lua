-- WX03-048 コードアンチ　クリスカル
-- 【出】：このシグニがトラッシュから場に出た場合、ターン終了時まで、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsPreviousLocation(LOCATION_TRASH) and h:IsLocation(LOCATION_SZONE)) then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_POWER)
    e1:SetValue(5000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
