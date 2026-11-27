-- WX12-011 花咲乱　遊月・参
-- 【自】：あなたのグロウフェイズ開始時、《赤×0》を支払ってもよい。そうした場合、このターン、あなたのセンタールリグの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    if not Duel.SelectYesNo(tp) then return end
    -- [の間] 「このターン」 센터 루리그의 【出】은 발동하지 않는다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE_ABILITY)
    e1:SetTargetRange(LOCATION_LRIG,0)
    e1:SetValue(ABILITY_ON_PLAY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
