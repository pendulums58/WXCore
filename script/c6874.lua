-- WXK08-088 小書　キンウギ
-- 【出】：あなたの＜ウェポン＞のシグニ１体を対象とし、あなたのデッキの一番上のカードをそれの下に置く。
-- （シグニの下に置かれるカードは表向きである）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Duel.GetDecktopGroup(tp,1)
      if g:GetCount()>0 then Duel.PutUnder(tc,g) end
    end
  end)
  c:RegisterEffect(e1)
end
