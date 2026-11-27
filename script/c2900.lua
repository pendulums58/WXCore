-- WX17-006 避難勧告
-- ベット―《コインアイコン》
-- あなたのシグニ１体を場からトラッシュに置く。
-- そうした場合、このターン、対戦相手のシグニ１体がアタックしたとき、そのアタックがこのターン一度目か二度目の場合、そのアタックを無効にする。あなたがベットしていた場合、追加でこのターン、対戦相手のセンタールリグがアタックしたとき、そのアタックを無効にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)==0 then return end
    -- [の間] 「このターン」 상대 시그니의 1·2번째 어택, ベット했으면 센터 루리그 어택을 무효
    local bet,n=Duel.IsBet(),0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()~=tp and (x:IsSigni() or (bet and x:IsType(TYPE_LRIG))) end)
    e1:SetOperation(function(e2,tp2,eg)
      local x=eg:GetFirst()
      if x:IsSigni() then n=n+1 if n>2 then return end end
      Duel.NegateAttack()
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
