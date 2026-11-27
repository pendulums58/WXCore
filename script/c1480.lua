-- WX21-050 幻怪　ワニュウドウ
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：このシグニは対戦相手の効果によってダウンしない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  c:RegisterEffect(e1)
end
