-- WX10-026 ペナルティ・チャンス
-- 以下の３つから１つを選ぶ。
-- ①あなたの手札が０枚の場合、カードを２枚引く。
-- ②対戦相手のシグニ１体を対象とし、あなたの場にシグニがない場合、それをダウンする。
-- ③このターンが効果によって追加されたターンである場合、このアタックフェイズを終了する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.Draw(tp,2) end
    elseif m==1 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()==0 then Duel.Down(tc) end
    elseif Duel.IsExtraTurn() and Duel.GetPhase()==PHASE_ATTACK then
      -- 「このアタックフェイズを終了する」: 남은 어택 스텝을 건너뛴다(근사)
      for _,code in ipairs({EFFECT_SKIP_SIGNI_ATTACK,EFFECT_SKIP_LRIG_ATTACK}) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(code)
        e1:SetTargetRange(1,1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
