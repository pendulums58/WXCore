-- WD21-017 羅星　≡センヤ≡
-- 【自】：このシグニが効果かレゾナの出現条件によって、バニッシュされるか場からトラッシュに置かれたとき、対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 배틀·룰 처리·코스트는 아니다(FAQ 2·3)
  for _,code in ipairs{EVENT_BANISHED,EVENT_TO_TRASH} do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(code)
    e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
      if (r&(REASON_EFFECT+REASON_RESONA))==0 then return false end
      -- 바니시 대신 트래시에 놓인 것은 바니시로 한 번만
      return code==EVENT_BANISHED or ((r&REASON_BANISH)==0 and e:GetHandler():IsPreviousLocation(LOCATION_SZONE))
    end)
    e1:SetTarget(aux.BanishPowerTarget(3000))
    e1:SetOperation(aux.BanishOp)
    c:RegisterEffect(e1)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
