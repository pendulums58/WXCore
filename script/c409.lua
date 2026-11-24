-- WD13-009 スピリット・サルベージ
-- あなたのルリグトラッシュから《スピリット・サルベージ》以外のアーツ１枚を対象とし、それをルリグデッキに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) and x:GetCode()~=id end,tp,LOCATION_LTRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToLrigDeck(tc) end
  end)
  c:RegisterEffect(e1)
end
