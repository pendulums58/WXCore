-- WX04-082 コードアート　Ｓ・Ｍ・Ｌ
-- 【自】：このシグニの正面のシグニがアタックしたとき、アタックしたそのシグニを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x==e:GetHandler():GetFrontCard() end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then Duel.Freeze(x) end
  end)
  c:RegisterEffect(e1)
end
