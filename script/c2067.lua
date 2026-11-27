-- WX04-099 ツヴァイ＝サリナ
-- 【自】：対戦相手のターンの間、このシグニが対戦相手のレベル２以下のシグニとバトルしたとき、バトル終了時に、その対戦相手のシグニをバニッシュする。（このシグニがバトルでバニッシュされていても、この能力は発動する）
local s,id=GetID()
function s.initial_effect(c)
  -- 배틀로 바니시되어도 발동한다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BATTLE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=Duel.GetBattleOpponent() return Duel.GetTurnPlayer()~=tp and x and x:GetLevel()<=2 end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetBattleOpponent()
    if x and x:IsLocation(LOCATION_SZONE) then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
end
