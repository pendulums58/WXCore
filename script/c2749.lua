-- WX15-006 愛別離苦
-- このアーツは対戦相手のターンにしか使用できない。
-- ベット―《コインアイコン》
-- このターン、あなたのシグニ１体があなたの効果以外によってバニッシュされたとき、対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- あなたがベットしていた場合、このターン、あなたのシグニ１体があなたの効果以外によってバニッシュされたとき、追加であなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetBet(1)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local bet=Duel.IsBet()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BANISHED)
    e1:SetCondition(function(e2,tp2,eg,ep,ev,re,r,rp) local x=eg:GetFirst() return x:GetOwner()==tp and (r&REASON_EFFECT==0 or rp~=tp) end)
    e1:SetOperation(function(e2)
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
      if bet then
        local x=Duel.GetDecktopGroup(tp,1):GetFirst()
        if x then Duel.SendToLife(x) end
      end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
