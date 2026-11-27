-- WX04-016 三式豊潤娘　緑姫
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【常】：あなたの＜空獣＞と＜地獣＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end)(x) end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
end
