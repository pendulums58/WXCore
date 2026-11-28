-- WXK10-008 怒髪衝炎
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①対戦相手のターンの場合、このターン、対戦相手のエナゾーンにあるカードは色と能力を失う。
-- ②対戦相手のパワー7000以下のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then
      -- 「エナゾーンにあるカードは色と能力を失う」(근사: 상대 에나 카드의 색을 무색으로)
      if not (Duel.GetTurnPlayer()~=tp) then return end
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_CHANGE_COLOR)
      e1:SetTargetRange(0,LOCATION_ENA)
      e1:SetValue(0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    else
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if not tc then return end
      if Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp) then
        Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
        Duel.Banish(tc)
      end
    end
  end)
  c:RegisterEffect(e1)
end
