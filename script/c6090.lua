-- WXEX1-56 白光と黒影　モノクロ
-- 【常】：対戦相手のターンの間、あなたの＜美巧＞のシグニのパワーを＋1000する。
-- 【常】：【コンバート《緑》】（エナコストを支払う際、このカードは《緑》として支払える）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  -- [の間] 【常】 【コンバート《緑》】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_ADD_PAY_COLOR)
  e2:SetRange(LOCATION_ENA)
  e2:SetValue(COLOR_GREEN)
  c:RegisterEffect(e2)
end
