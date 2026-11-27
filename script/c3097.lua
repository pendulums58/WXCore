-- WX19-077 羅菌　ＰＭ
-- 【常】：対戦相手の感染状態のシグニはアップフェイズにアップしない。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「アップフェイズにアップしない」: 내 턴 종료 시 상대의 감염 상태인 시그니를 동결하는 것으로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetAbilityType(ABILITY_CONTINUOUS)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(x) end
  end)
  c:RegisterEffect(e1)
end
