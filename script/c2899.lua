-- WX17-005 鎧終一触
-- ベット―《コインアイコン》
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それを《サーバント　ＺＥＲＯ》にする。あなたがベットしていた場合、代わりにターン終了時まで、対戦相手のすべてのシグニを《サーバント　ＺＥＲＯ》にする。
-- （《サーバント　ＺＥＲＯ》はレベル１、＜精元＞、パワー1000、無色で能力を持たないシグニである）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetOperation(function(e,tp)
    -- 「《サーバント　ＺＥＲＯ》にする」: 능력 상실·기본 파워 1000·레벨 1로 근사(색·클래스는 그대로)
    local g=Duel.IsBet() and Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil) or Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    for tc in g:Iter() do
    local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_SET_BASE_POWER)
      e2:SetValue(1000)
      e2:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e2)
      local e3=Effect.CreateEffect(e:GetHandler())
      e3:SetType(EFFECT_TYPE_SINGLE)
      e3:SetCode(EFFECT_CHANGE_LEVEL)
      e3:SetValue(1)
      e3:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e3)
    end
  end)
  c:RegisterEffect(e1)
end
