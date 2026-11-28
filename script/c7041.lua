-- WXK10-067 コードアンチ　モンデス
-- 【出】《赤》：あなたの他の＜古代兵器＞のシグニ１体を対象とし、あなたのデッキからそれと同じ名前のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsCardName(tc:GetCode()) end,1)
    end
  end)
  c:RegisterEffect(e1)
end
