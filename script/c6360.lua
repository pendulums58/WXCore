-- WXK02-084 験英の器具　フラスコ
-- 【出】《青》：あなたのシグニ１体を対象とし、ターン終了時まで、それは「【常】：このシグニの正面に凍結状態のシグニがあるかぎり、このシグニは【アサシン】を得る。」を得る。
-- （【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EFFECT_ASSASSIN)
      g:SetRange(LOCATION_SZONE)
      g:SetCondition(function(e2) local f=e2:GetHandler():GetFrontCard() return f and f:IsFrozen() end)
      g:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e1)
end
