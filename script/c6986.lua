-- WXK10-012 停空飛翔
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①このターン、対戦相手のセンタールリグとシグニはアップしない。
-- ②《緑》を支払ってもよい。そうした場合、このターン、対戦相手のセンタールリグがアタックしたとき、そのアタックを無効にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then
      -- 「このターン、対戦相手のセンタールリグとシグニはアップしない」(근사: 상대 턴의 업 페이즈가 아니라 이 턴 효과 업 금지는 아직)
    else
      if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_NEGATE_NEXT_ATTACK)
      e1:SetTargetRange(0,1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
