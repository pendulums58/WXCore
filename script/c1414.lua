-- WX11-058 中盾　ブメルド
-- 【自】《ターン１回》：あなたの＜アーム＞のシグニ１体が効果によって場に出たとき、カードを１枚引く。（このシグニが効果によって場に出た時も発動する）
local s,id=GetID()
function s.initial_effect(c)
  -- 자신도(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) and r&REASON_EFFECT~=0 end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
