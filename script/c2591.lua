-- WX13-009 博愛の使者　サシェ・カルティエ
-- 【出】：あなたのトラッシュから白のシグニ１枚を対象とし、それを場に出す。ターン終了時、それを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if not (tc and Duel.PutOnField(tc,tp)) then return end
    -- 「ターン終了時、それを場からトラッシュに置く」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetOperation(function() if tc:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(tc,REASON_EFFECT) end end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
