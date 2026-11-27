-- WX17-072 丸英の集合　＃ベンズ＃
-- 【出】英知＝７：ターン終了時まで、このシグニは「【常】：バニッシュされない。」を得る。
-- （あなたの場にある＜英知＞のシグニのレベルの合計がちょうど７であるかぎり有効になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(7))
  e1:SetOperation(function(e,tp)
    local tc=e:GetHandler()
    if tc:IsLocation(LOCATION_SZONE) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BANISH)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
