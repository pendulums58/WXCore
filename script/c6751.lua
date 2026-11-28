-- WXK07-053 羅星　メガビュウ
-- 【自】：このシグニがアタックしたとき、あなたの場にあるシグニのレベルの合計が対戦相手の場にあるシグニのレベルの合計と同じ場合、カードを１枚引く。
-- 【出】：レベル２以上の他のシグニ１体を対象とし、ターン終了時まで、それのレベルを－１する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)==(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(1-tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()>=2 end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_LEVEL)
      e1:SetValue(-1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
