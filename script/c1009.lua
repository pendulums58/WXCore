-- SPK01-04 讃の遊　ベッドメリー（パーティーパックVol.2）
-- 【自】《ターン１回》：あなたのアタックフェイズの間、シグニ１体が場から手札に戻ったとき、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  -- 어느 쪽 시그니든(FAQ 1). 업 상태여도 발동해 횟수를 쓴다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp or Duel.GetPhase()~=PHASE_ATTACK then return false end
    for x in eg:Iter() do if x:IsType(TYPE_SIGNI) and x:IsPreviousLocation(LOCATION_SZONE) then return true end end
    return false
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
end
