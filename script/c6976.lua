-- WXK10-001 サンフラワーファイヤー
-- 対戦相手のセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。その後、そのルリグと同じレベルの対戦相手のシグニ１体を対象とし、それを手札に戻し、そのルリグより低いレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local lc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
    if not lc then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(e1)
    local lv=lc:GetLevel()
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if a then Duel.SendToHand(a) end
    local b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if b then Duel.Banish(b) end
  end)
  c:RegisterEffect(e1)
end
