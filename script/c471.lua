-- WX05-014 十人十色
-- このターン、あなたの＜美巧＞のシグニは対戦相手の、スペルとシグニの効果を受けない。（このアーツの処理後に場に出たシグニにもこの効果は影響を与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 나중에 나온 시그니도
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) end)
    e1:SetValue(function(e,sc,sp) return sp~=tp and (sc:IsSigni() or sc:IsType(TYPE_SPELL)) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
