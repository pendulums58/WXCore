-- WXK07-088 羅星　リング
-- 【出】《黒》：対戦相手のシグニ１体を対象とし、あなたの場にあるシグニのレベルの合計が５の場合、ターン終了時まで、それのパワーを－3000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)==5 then aux.AddPower(e,tc,-3000) end
    end
  end)
  c:RegisterEffect(e1)
end
