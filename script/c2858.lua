-- WX16-040 大罠　ゴエモン
-- 【自】：あなたの《トラップアイコン》が発動したとき、《青》を支払ってもよい。そうした場合、このシグニをトラッシュから場に出す。ターン終了時に、またはこのシグニが場から離れる場合に、このシグニをゲームから除外する。
-- ライフバースト：カードを２枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TRAP)
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_TRASH) and Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    if not Duel.PutOnField(h,tp) then return end
    -- 떠나면 제외(근사: 【常】 「場を離れる場合ゲームから除外」), 턴 종료 시 제외
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_EXCLUDE)
    h:RegisterEffect(e1)
    local e2=Effect.CreateEffect(h)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_TURN_END)
    e2:SetOperation(function() if h:IsLocation(LOCATION_SZONE) then Duel.Exclude(h) end end)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
end
