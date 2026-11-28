-- SP26-002 アンチ・アビリティ（「Lostorage incited WIXOSS 3」 初回特典）
-- このアーツは対戦相手のターンにしか使用できない。
-- このターン、すべての領域にある【ライフバースト】以外の対戦相手のシグニのトリガー能力は発動しない。
-- （「～したとき、」「～時、」と書かれた能力、【出】、【自】、《トラップアイコン》、【ライフバースト】、はトリガー能力である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 모든 영역의 상대 시그니. 이미 트리거해 발동 전인 것도(FAQ 1). 이미 처리한 것은 그대로(FAQ 3)
    local all=LOCATION_SIGNI+LOCATION_CHEER+LOCATION_HAND+LOCATION_MDECK+LOCATION_LIFE+LOCATION_CHECK+LOCATION_TRASH+LOCATION_ENA+LOCATION_EXCLUDE+LOCATION_TRAP+LOCATION_ACCE
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE_ABILITY)
    e1:SetTargetRange(0,all)
    e1:SetTarget(function(e2,x) return x:IsType(TYPE_SIGNI) end)
    e1:SetValue(ABILITY_AUTO+ABILITY_ON_PLAY+ABILITY_TRAP)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
