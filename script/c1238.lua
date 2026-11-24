-- WD13-014 天使の加護　オーディン
-- 【常】：対戦相手のターンの間、このシグニの基本パワーは15000になる。
-- 【常】：あなたの手札にある＜天使＞のシグニは《ガードアイコン》を持つ。
-- ライフバースト：対戦相手のセンタールリグかシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_GUARD_ICON)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_HAND,0)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG+LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e3)
end
