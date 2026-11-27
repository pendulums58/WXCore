-- WX10-058 羅星　タンサーワン
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは5000になる。
-- 【起】《白×0》：ターン終了時まで、このシグニの基本レベルは３になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(3)
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
