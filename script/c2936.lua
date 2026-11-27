-- WX17-052 幻怪　トロル
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、このシグニをエナゾーンから手札に加えてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_BANISHED)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  g:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_ENA) and Duel.SelectYesNo(tp) then Duel.SendToHand(h) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetCode(EFFECT_GRANT)
  e1:SetAbilityType(ABILITY_AUTO)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
