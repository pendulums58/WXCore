-- WXK10-010 ドント・コール
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①このターン、対戦相手は自分の効果によって、カードを引いたりカードを手札に加えることができない。
-- ②対戦相手のシグニ１体を対象とし、《青》を支払ってもよい。そうした場合、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then
      -- 「カードを引いたりカードを手札に加えることができない」(근사: 상대의 효과 드로·패에 넣기 금지)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_NO_HAND_ADD)
      e1:SetTargetRange(0,1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if not tc then return end
      if Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp) then
        Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
        Duel.Down(tc)
      end
    end
  end)
  c:RegisterEffect(e1)
end
