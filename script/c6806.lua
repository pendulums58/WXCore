-- WXK08-017 奇跡世代
-- ターン終了時まで、あなたは「【常】：あなたがダメージを受ける場合、代わりにダメージを受けず、この能力を失う。」を得る。その後、あなたのキー１枚を場からルリグトラッシュに置いてもよい。そうした場合、対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- [まで] ターン終了時まで. 한 번 막으면 사라진다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local kg=Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil)
    if kg:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,kg,1,1),REASON_EFFECT)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if x then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e1)
end
