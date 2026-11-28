-- WXK10-089 羅星　カニセー
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの場にあるシグニのレベルの合計が対戦相手の場にあるシグニのレベルの合計以下の場合、ターン終了時まで、それのパワーをあなたの場にあるシグニのレベルの合計１につき－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)<=(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(1-tp) then aux.AddPower(e,tc,-1000*(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)) end
    end
  end)
  c:RegisterEffect(e1)
end
