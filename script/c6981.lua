-- WXK10-007 イレイザー・スマッシュ
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①対戦相手のセンタールリグ１体を対象とし、対戦相手のターンの場合、ターン終了時まで、それは能力を失い、新たに得られない。
-- ②対戦相手のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、ターン終了時まで、それは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then
      if not (Duel.GetTurnPlayer()~=tp) then return end
      local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
      if not tc then return end
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if not tc then return end
      if Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp) then
        Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:GrantEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
