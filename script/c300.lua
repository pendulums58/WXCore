-- PR-472 １日シグニ　タマヨリヒメ（コロコロアニキ2020年冬号 付録）
-- 【常】：このシグニのパワーはあなたのセンタールリグのルリグタイプ１つにつき＋2000される。
-- 【常】：あなたのセンタールリグのルリグタイプが２つ以上であるかぎり、対戦相手はスペルを使用できない。
-- 【常】：【マルチエナ】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) local tp=e:GetHandlerPlayer() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and 2000*#lc:GetLrigTypes() or 0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_CANNOT_USE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,1)
  e2:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
  e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and #lc:GetLrigTypes()>=2 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_MULTI_ENA)
  e3:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e3)
end
