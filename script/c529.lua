-- WD18-008 悠々自適
-- ベット―《コインアイコン》
-- ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。あなたがベットしていた場合、追加でターン終了時まで、対象のあなたのシグニ１体は「【常】：対戦相手のターンであるかぎり、対戦相手の効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.IsBet() then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    aux.AddPower(e,tc,2000)  -- [まで] ターン終了時まで. 처리할 때 장에 있는 시그니만
  end
  local tc=Duel.GetFirstTarget()
  if not (Duel.IsBet() and tc and tc:IsRelateToEffect(e)) then return end
  -- [まで] ターン終了時まで 「【常】：対戦相手のターンであるかぎり、対戦相手の効果を受けない。」를 얻는다
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  e1:SetReset(RESET_PHASE+PHASE_END)
  tc:GrantEffect(e1)
end
