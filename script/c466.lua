-- SP07-001 天啓の天恵　アン=フォース（「selector spread WIXOSS」 BOX2 初回限定特典）
-- 【常】：《天啓の天恵　アン=フォース》のグロウコストとして《白》を支払う際、代わりにあなたのエナゾーンから＜美巧＞のシグニ１枚をトラッシュに置いてもよい。
-- 【常】：あなたの＜美巧＞のシグニのパワーを＋1000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 이 카드의 그로우 코스트를 낼 때만: 그로우 선언 때 켜고 코스트를 낸 뒤 끈다
  local paying=false
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LDECK)
  e1:SetCode(EFFECT_ADD_PAY_COLOR)
  e1:SetTargetRange(LOCATION_ENA,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)
  e1:SetValue(COLOR_WHITE)
  e1:SetCondition(function() return paying end)
  c:RegisterEffect(e1)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetDeclare(function() paying=true end)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    paying=false
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
end
