-- WXK07-082 羅星　ベイル
-- 【出】：あなたのトラッシュから【ライフバースト】を持たず無色ではないレベル４のシグニ１枚を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==4 and x:GetColor()~=0 and not x:IsLifeBurst() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e1)
end
