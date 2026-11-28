-- WXEX1-72 肆ノ遊　カーケシ
-- 【自】：このシグニが＜遊具＞のレゾナの出現条件のために場からトラッシュに置かれたとき、次のあなたのターンまで、そのレゾナはバニッシュされない。
-- 【出】：このターン、次にクラッシュされる対戦相手のライフクロスの一番上のカードのライフバーストは発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    if r&REASON_RESONA==0 or not e:GetHandler():IsPreviousLocation(LOCATION_SZONE) then return false end
    local rc=re and re:GetHandler()
    return rc and rc:IsClass(0,RACE_YUGU)
  end)
  e1:SetOperation(function(e,tp,eg,ep,ev,re)
    local rc=re and re:GetHandler()
    if rc and rc:IsLocation(LOCATION_SZONE) then
      -- [まで] 次のあなたのターンまでバニッシュされない
      local e0=Effect.CreateEffect(e:GetHandler())
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_CANNOT_BANISH)
      e0:SetReset(RESET_PHASE+PHASE_END+RESET_MY_TURN)
      rc:RegisterEffect(e0)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    -- 次にクラッシュされるライフクロスのLB不発はまだ
  end)
  c:RegisterEffect(e2)
end
