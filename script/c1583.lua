-- WDK01-017 コードライド　ゴーカート
-- 【自】：このシグニがドライブ状態になったとき、対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
-- （ルリグがシグニに乗るとそれらはドライブ状態になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRIVE)
  e1:SetTarget(aux.BanishPowerTarget(3000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
