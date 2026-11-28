-- WXK03-060 コードライド　ユウビンシャ
-- 【自】：あなたのターン終了時、このターンにあなたのセンタールリグがアタックしていなかった場合、【エナチャージ１】をする。
-- （ドライブ状態のシグニがアタックしてもそのシグニに乗っているルリグはアタックしていない）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 무효가 된 어택도 어택이다(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return Duel.GetTurnPlayer()==tp and lc and not lc:HasAttacked() end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
