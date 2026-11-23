-- WD19-007 シックネス・ラブ
-- ベット―《コインアイコン》
-- 対戦相手の感染状態のシグニ１体を対象とし、それと同じシグニゾーンにある【ウィルス】１つを取り除き、ターン終了時まで、それのパワーを－8000する。あなたがベットしていた場合、代わりに－15000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 【ウィルス】를 먼저 치우고 －한다(FAQ 1: 감염 상태를 보는 효과는 치운 뒤 사라진다)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e)) then return end
  local z=tc:GetZone()
  if z then Duel.RemoveVirus(z) end
  -- [まで] ターン終了時まで
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetValue(Duel.IsBet() and -15000 or -8000)
  e1:SetReset(RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
end
