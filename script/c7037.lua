-- WXK10-063 コードライド　ウンパン
-- 【自】：あなたのドライブ状態のシグニ１体が対戦相手のライフクロス１枚をクラッシュしたとき、あなたのセンタールリグ１体を対象とし、それはすべてのシグニから降りてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) local x=Duel.GetCrusher() return ep~=tp and x and x:IsSigni() and x:IsDrive() and x:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectYesNo(tp) then Duel.Unride(tp) end
  end)
  c:RegisterEffect(e1)
end
