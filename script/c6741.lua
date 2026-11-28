-- WXK07-043 羅菌　マグネ
-- 【自】：対戦相手のアタックフェイズ開始時、このシグニに【チャーム】が付いている場合、ターン終了時まで、このシグニは「【常】：バニッシュされない。」を得る。
-- 【自】：対戦相手のターン終了時、【エナチャージ１】をする。このシグニに【チャーム】が付いている場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetCharm()~=nil end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_CANNOT_BANISH) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetOperation(function(e,tp,eg)
    Duel.EnaCharge(tp,1)
    if e:GetHandler():GetCharm() then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
