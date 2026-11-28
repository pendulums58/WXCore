-- WXK01-109 小罠　ネズミコ
-- 【出】：あなたのトラッシュからレベル２以下の＜トリック＞のシグニを１枚まで対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_TRICK) end)(x) and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e1)
end
