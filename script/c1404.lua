-- WDK-F03-08 イレイズ・ルフラン
-- ベット―《コインアイコン》
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。あなたがベットしていた場合、代わりに対戦相手のすべてのシグニは能力を失う。
-- （このアーツの後に得た能力や場に出たシグニの能力は失われない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- ベット하면 대상을 정하지 않는다(그래서 【シャドウ】도 잃게 할 수 있다. FAQ 2)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  if not Duel.IsBet() then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
end
function s.lose(e,tc)
  -- [まで] ターン終了時まで. 처리할 때 장에 있던 시그니만(나중에 나온 시그니·나중에 얻은 능력은 그대로)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_LOSE_ABILITY)
  e1:SetReset(RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
end
function s.op(e,tp)
  if Duel.IsBet() then
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do s.lose(e,tc) end
    return
  end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then s.lose(e,tc) end
end
